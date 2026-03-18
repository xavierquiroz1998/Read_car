import '../../../domain/repositories/bluetooth_repository.dart';
import '../../../domain/entities/ble_device.dart';

class ScanDevicesUseCase {
  final BluetoothRepository _repository;
  ScanDevicesUseCase(this._repository);

  Stream<List<BleDevice>> call() => _repository.scanDevices();
}
