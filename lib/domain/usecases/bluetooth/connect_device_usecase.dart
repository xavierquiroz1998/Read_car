import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/repositories/bluetooth_repository.dart';

class ConnectDeviceUseCase {
  final BluetoothRepository _repository;
  ConnectDeviceUseCase(this._repository);

  Future<Either<Failure, void>> call(String deviceId) =>
      _repository.connectDevice(deviceId);
}
