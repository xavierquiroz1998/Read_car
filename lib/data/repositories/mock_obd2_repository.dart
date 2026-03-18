import 'dart:async';
import 'dart:math';

import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/fuel_calculator.dart';
import '../../domain/entities/dtc_code.dart';
import '../../domain/entities/vehicle_data.dart';
import '../../domain/repositories/obd2_repository.dart';

/// Simulates a live OBD2 connection without real Bluetooth hardware.
/// Use this in the emulator or during UI development.
///
/// Simulates a realistic drive cycle:
///   - Speed ramps up from 0 → 120 km/h and back down
///   - RPM follows speed with slight lag
///   - Engine load correlates with RPM
///   - Coolant temp warms up from 20°C to 90°C over 60s
///   - Fuel level slowly decreases
class MockObd2Repository implements Obd2Repository {
  final _random = Random();
  StreamController<Either<Failure, VehicleData>>? _controller;
  Timer? _timer;

  // Internal simulation state
  double _speed = 0;
  double _rpm = 800;
  double _coolant = 20;
  double _fuelLevel = 75;
  double _load = 15;
  int _tick = 0;
  bool _accelerating = true;

  @override
  Future<Either<Failure, void>> initialize() async {
    // Simulate a brief init delay
    await Future.delayed(const Duration(milliseconds: 800));
    return const Right(null);
  }

  @override
  Stream<Either<Failure, VehicleData>> vehicleDataStream() {
    _controller?.close();
    _controller = StreamController<Either<Failure, VehicleData>>.broadcast();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      _tick++;
      _simulate();
      _controller?.add(Right(_buildSnapshot()));
    });

    return _controller!.stream;
  }

  void _simulate() {
    // ── Speed ramp: 0→120→0 every ~120 ticks ─────────────────────────────
    if (_accelerating) {
      _speed += 1.2 + _random.nextDouble() * 0.5;
      if (_speed >= 115 + _random.nextDouble() * 10) _accelerating = false;
    } else {
      _speed -= 1.0 + _random.nextDouble() * 0.5;
      if (_speed <= 5) {
        _speed = 0;
        _accelerating = true;
      }
    }
    _speed = _speed.clamp(0, 140);

    // ── RPM follows speed with idle floor ────────────────────────────────
    final targetRpm = _speed > 5
        ? 800 + (_speed * 30) + _random.nextDouble() * 200 - 100
        : 750 + _random.nextDouble() * 50;
    _rpm += (targetRpm - _rpm) * 0.15; // smooth lag
    _rpm = _rpm.clamp(650, 7000);

    // ── Engine load ───────────────────────────────────────────────────────
    final targetLoad = _speed > 5
        ? 20 + (_speed * 0.4) + _random.nextDouble() * 10
        : 15 + _random.nextDouble() * 5;
    _load += (targetLoad - _load) * 0.2;
    _load = _load.clamp(0, 100);

    // ── Coolant warms up to 90°C then holds ──────────────────────────────
    if (_coolant < 88) {
      _coolant += 0.3 + _random.nextDouble() * 0.1;
    } else {
      _coolant = 88 + _random.nextDouble() * 4;
    }

    // ── Fuel slowly drains ────────────────────────────────────────────────
    if (_tick % 20 == 0 && _fuelLevel > 0) {
      _fuelLevel -= 0.05;
    }
  }

  VehicleData _buildSnapshot() {
    final consumption = FuelCalculator.estimateLPer100km(
      rpm: _rpm,
      engineLoadPercent: _load,
      speedKmh: _speed.toInt(),
    );

    return VehicleData(
      speedKmh: _speed.toInt(),
      rpm: double.parse(_rpm.toStringAsFixed(0)),
      coolantTempC: _coolant.toInt(),
      fuelLevelPercent: double.parse(_fuelLevel.toStringAsFixed(1)),
      engineLoadPercent: double.parse(_load.toStringAsFixed(1)),
      fuelConsumptionLPer100km: consumption,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<Either<Failure, List<DtcCode>>> readDtcCodes() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Simulate 2 sample fault codes
    return Right([
      DtcCode(code: 'P0300', detectedAt: DateTime.now()),
      DtcCode(code: 'P0420', detectedAt: DateTime.now()),
    ]);
  }

  @override
  Future<Either<Failure, void>> clearDtcCodes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> sendRawCommand(String command) async {
    return Right('MOCK:$command→OK');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.close();
  }
}
