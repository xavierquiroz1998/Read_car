import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/repositories/obd2_repository.dart';

class ClearDtcUseCase {
  final Obd2Repository _repository;
  ClearDtcUseCase(this._repository);

  Future<Either<Failure, void>> call() => _repository.clearDtcCodes();
}
