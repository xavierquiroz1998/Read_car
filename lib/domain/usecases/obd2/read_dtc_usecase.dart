import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/dtc_code.dart';
import '../../../domain/repositories/obd2_repository.dart';

class ReadDtcUseCase {
  final Obd2Repository _repository;
  ReadDtcUseCase(this._repository);

  Future<Either<Failure, List<DtcCode>>> call() =>
      _repository.readDtcCodes();
}
