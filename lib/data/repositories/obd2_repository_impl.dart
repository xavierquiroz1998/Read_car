import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/obd2_commands.dart';
import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/fuel_calculator.dart';
import '../../core/utils/obd2_parser.dart';
import '../../data/datasources/obd2/obd2_datasource_impl.dart';
import '../../domain/entities/dtc_code.dart';
import '../../domain/entities/vehicle_data.dart';
import '../../domain/repositories/obd2_repository.dart';

class Obd2RepositoryImpl implements Obd2Repository {
  final Obd2DataSourceImpl _dataSource;
  final Logger _log = Logger(printer: PrettyPrinter(methodCount: 0));

  StreamController<Either<Failure, VehicleData>>? _streamController;
  Timer? _pollingTimer;
  bool _initialized = false;

  Obd2RepositoryImpl(this._dataSource);

  /// Wire up the BLE characteristics obtained after connection.
  void attachDevice(BluetoothDevice device) async {
    final services = await device.discoverServices();

    BluetoothCharacteristic? writeChar;
    BluetoothCharacteristic? notifyChar;

    // ELM327 adapters typically use a serial-over-BLE service.
    // Common service UUIDs vary by manufacturer — scan all services.
    for (final service in services) {
      for (final char in service.characteristics) {
        final props = char.properties;
        if (props.writeWithoutResponse || props.write) {
          writeChar ??= char;
        }
        if (props.notify || props.indicate) {
          notifyChar ??= char;
          await char.setNotifyValue(true);
        }
      }
    }

    if (writeChar == null || notifyChar == null) {
      _log.e('Could not find required BLE characteristics');
      return;
    }

    _dataSource.attachCharacteristics(
      writeCharacteristic: writeChar,
      notifyCharacteristic: notifyChar,
    );

    _log.i('OBD2 characteristics attached');
  }

  @override
  Future<Either<Failure, void>> initialize() async {
    _log.i('Initializing ELM327…');

    // ATZ needs extra time to reset the chip
    final resetResult = await _dataSource.sendCommand(Obd2Commands.reset);
    if (resetResult.isLeft) return resetResult.fold(Left.new, (_) => const Right(null));

    await Future.delayed(AppConstants.resetDelay);

    // Send remaining init commands
    for (final cmd in Obd2Commands.initSequence.skip(1)) {
      final result = await _dataSource.sendCommand(cmd);
      if (result.isLeft) {
        _log.w('Init command $cmd failed — continuing anyway');
      }
    }

    _initialized = true;
    _log.i('ELM327 initialized');
    return const Right(null);
  }

  @override
  Stream<Either<Failure, VehicleData>> vehicleDataStream() {
    _streamController?.close();
    _streamController =
        StreamController<Either<Failure, VehicleData>>.broadcast();

    _startPolling();

    return _streamController!.stream;
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    VehicleData current = VehicleData.empty();

    _pollingTimer = Timer.periodic(AppConstants.pollingInterval, (_) async {
      if (_streamController == null || _streamController!.isClosed) return;

      try {
        current = await _pollOneCycle(current);
        _streamController?.add(Right(current));
      } catch (e) {
        _streamController?.add(Left(ConnectionFailure(e.toString())));
      }
    });
  }

  Future<VehicleData> _pollOneCycle(VehicleData previous) async {
    int speed = previous.speedKmh;
    double rpm = previous.rpm;
    int coolant = previous.coolantTempC;
    double fuel = previous.fuelLevelPercent;
    double load = previous.engineLoadPercent;

    // Poll each PID — failures use the previous value (graceful degradation)
    final speedRes = await _dataSource.sendCommand(Obd2Commands.speed);
    speedRes.fold(
      (_) {},
      (raw) {
        if (!Obd2Parser.isNoData(raw)) {
          try { speed = Obd2Parser.parseSpeed(raw); } catch (_) {}
        }
      },
    );

    final rpmRes = await _dataSource.sendCommand(Obd2Commands.rpm);
    rpmRes.fold(
      (_) {},
      (raw) {
        if (!Obd2Parser.isNoData(raw)) {
          try { rpm = Obd2Parser.parseRpm(raw); } catch (_) {}
        }
      },
    );

    final tempRes = await _dataSource.sendCommand(Obd2Commands.coolantTemp);
    tempRes.fold(
      (_) {},
      (raw) {
        if (!Obd2Parser.isNoData(raw)) {
          try { coolant = Obd2Parser.parseCoolantTemp(raw); } catch (_) {}
        }
      },
    );

    final fuelRes = await _dataSource.sendCommand(Obd2Commands.fuelLevel);
    fuelRes.fold(
      (_) {},
      (raw) {
        if (!Obd2Parser.isNoData(raw)) {
          try { fuel = Obd2Parser.parseFuelLevel(raw); } catch (_) {}
        }
      },
    );

    final loadRes = await _dataSource.sendCommand(Obd2Commands.engineLoad);
    loadRes.fold(
      (_) {},
      (raw) {
        if (!Obd2Parser.isNoData(raw)) {
          try { load = Obd2Parser.parseEngineLoad(raw); } catch (_) {}
        }
      },
    );

    final consumption = FuelCalculator.estimateLPer100km(
      rpm: rpm,
      engineLoadPercent: load,
      speedKmh: speed,
    );

    return VehicleData(
      speedKmh: speed,
      rpm: rpm,
      coolantTempC: coolant,
      fuelLevelPercent: fuel,
      engineLoadPercent: load,
      fuelConsumptionLPer100km: consumption,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<Either<Failure, List<DtcCode>>> readDtcCodes() async {
    final result = await _dataSource.sendCommand(Obd2Commands.readDtc);
    return result.fold(
      Left.new,
      (raw) {
        try {
          final codes = Obd2Parser.parseDtcCodes(raw);
          final entities = codes
              .map((code) => DtcCode(code: code, detectedAt: DateTime.now()))
              .toList();
          return Right(entities);
        } catch (e) {
          return Left(InvalidResponseFailure(raw));
        }
      },
    );
  }

  @override
  Future<Either<Failure, void>> clearDtcCodes() async {
    final result = await _dataSource.sendCommand(Obd2Commands.clearDtc);
    return result.fold(Left.new, (_) => const Right(null));
  }

  @override
  Future<Either<Failure, String>> sendRawCommand(String command) =>
      _dataSource.sendCommand(command);

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _streamController?.close();
    _dataSource.dispose();
    _initialized = false;
  }
}
