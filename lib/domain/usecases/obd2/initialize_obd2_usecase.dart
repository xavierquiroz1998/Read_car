import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/repositories/obd2_repository.dart';

class InitializeObd2UseCase {
  final Obd2Repository _repository;
  InitializeObd2UseCase(this._repository);

  Future<Either<Failure, void>> call() => _repository.initialize();
}
