import 'dart:async';

import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/ble_device.dart';
import '../../domain/repositories/bluetooth_repository.dart';

/// Fake Bluetooth repository for emulator / demo mode.
/// Simulates finding one ELM327 device and connecting instantly.
class MockBluetoothRepository implements BluetoothRepository {
  final _connectionController = StreamController<bool>.broadcast();
  bool _connected = false;

  static const _fakeDevice = BleDevice(
    id: 'mock-elm327-001',
    name: 'OBDII ELM327 (Demo)',
    rssi: -58,
    isConnected: false,
  );

  @override
  Stream<List<BleDevice>> scanDevices() async* {
    // Simulate scan finding device after 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 500));
    yield [_fakeDevice];
    await Future.delayed(const Duration(milliseconds: 1000));
    yield [_fakeDevice]; // second emission simulates ongoing scan
  }

  @override
  Future<Either<Failure, void>> stopScan() async => const Right(null);

  @override
  Future<Either<Failure, void>> connectDevice(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _connected = true;
    _connectionController.add(true);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> disconnectDevice() async {
    _connected = false;
    _connectionController.add(false);
    return const Right(null);
  }

  @override
  Stream<bool> connectionStateStream() => _connectionController.stream;

  @override
  bool get isConnected => _connected;

  void dispose() => _connectionController.close();
}
