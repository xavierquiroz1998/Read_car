import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/vehicle_data.dart';
import '../../../domain/repositories/obd2_repository.dart';

class FetchVehicleDataUseCase {
  final Obd2Repository _repository;
  FetchVehicleDataUseCase(this._repository);

  /// Returns a continuous stream of vehicle data readings.
  Stream<Either<Failure, VehicleData>> call() =>
      _repository.vehicleDataStream();
}
