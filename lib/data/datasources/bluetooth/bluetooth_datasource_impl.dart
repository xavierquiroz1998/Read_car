import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';

import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import 'bluetooth_datasource.dart';

class BluetoothDataSourceImpl implements BluetoothDataSource {
  final Logger _log = Logger(printer: PrettyPrinter(methodCount: 0));

  @override
  Stream<List<ScanResult>> startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    return FlutterBluePlus.scanResults;
  }

  @override
  Future<Either<Failure, void>> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      return const Right(null);
    } catch (e) {
      return Left(ConnectionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BluetoothDevice>> connectToDevice(
      String deviceId) async {
    try {
      // Use the last scan results (synchronous list, not a Future)
      final results = FlutterBluePlus.lastScanResults;

      final scanResult = results.cast<ScanResult?>().firstWhere(
            (r) => r?.device.remoteId.str == deviceId,
            orElse: () => null,
          );

      if (scanResult == null) {
        return Left(DeviceNotFoundFailure(deviceId));
      }

      final device = scanResult.device;
      await device.connect(timeout: const Duration(seconds: 15));
      _log.i('Connected to ${device.platformName}');
      return Right(device);
    } catch (e) {
      _log.e('Connection failed: $e');
      return Left(ConnectionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> disconnectDevice(
      BluetoothDevice device) async {
    try {
      await device.disconnect();
      return const Right(null);
    } catch (e) {
      return Left(ConnectionFailure(e.toString()));
    }
  }

  @override
  Stream<BluetoothConnectionState> deviceConnectionState(
          BluetoothDevice device) =>
      device.connectionState;
}
