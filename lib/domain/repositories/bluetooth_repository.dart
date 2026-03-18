import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../entities/ble_device.dart';

/// Contract for Bluetooth scanning and connection management.
/// Concrete implementation lives in the data layer.
abstract class BluetoothRepository {
  /// Stream of discovered Bluetooth devices during a scan.
  Stream<List<BleDevice>> scanDevices();

  /// Stop the current scan.
  Future<Either<Failure, void>> stopScan();

  /// Connect to a device by [deviceId].
  Future<Either<Failure, void>> connectDevice(String deviceId);

  /// Disconnect from the currently connected device.
  Future<Either<Failure, void>> disconnectDevice();

  /// Stream of connection state changes. Emits `true` when connected.
  Stream<bool> connectionStateStream();

  /// Whether a device is currently connected.
  bool get isConnected;
}
