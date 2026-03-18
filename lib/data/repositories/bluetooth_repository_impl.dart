import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/bluetooth/bluetooth_datasource.dart';
import '../../domain/entities/ble_device.dart';
import '../../domain/repositories/bluetooth_repository.dart';

class BluetoothRepositoryImpl implements BluetoothRepository {
  final BluetoothDataSource _dataSource;

  BluetoothDevice? _connectedDevice;

  BluetoothRepositoryImpl(this._dataSource);

  @override
  Stream<List<BleDevice>> scanDevices() {
    return _dataSource.startScan().map((results) {
      return results
          .where((r) => r.device.platformName.isNotEmpty)
          .map((r) => BleDevice(
                id: r.device.remoteId.str,
                name: r.device.platformName,
                rssi: r.rssi,
              ))
          .toList();
    });
  }

  @override
  Future<Either<Failure, void>> stopScan() => _dataSource.stopScan();

  @override
  Future<Either<Failure, void>> connectDevice(String deviceId) async {
    final result = await _dataSource.connectToDevice(deviceId);
    return result.fold(
      Left.new,
      (device) {
        _connectedDevice = device;
        return const Right(null);
      },
    );
  }

  @override
  Future<Either<Failure, void>> disconnectDevice() async {
    if (_connectedDevice == null) return const Right(null);
    final result = await _dataSource.disconnectDevice(_connectedDevice!);
    if (result.isRight) _connectedDevice = null;
    return result;
  }

  @override
  Stream<bool> connectionStateStream() {
    if (_connectedDevice == null) return Stream.value(false);
    return _dataSource
        .deviceConnectionState(_connectedDevice!)
        .map((s) => s == BluetoothConnectionState.connected);
  }

  @override
  bool get isConnected =>
      _connectedDevice != null &&
      _connectedDevice!.isConnected;

  /// Expose the connected BluetoothDevice for the OBD2 layer to use.
  BluetoothDevice? get connectedDevice => _connectedDevice;

  /// Check if a device name looks like an ELM327 adapter.
  static bool isLikelyElm327(String name) {
    final lower = name.toLowerCase();
    return AppConstants.elm327Names.any((n) => lower.contains(n));
  }
}
