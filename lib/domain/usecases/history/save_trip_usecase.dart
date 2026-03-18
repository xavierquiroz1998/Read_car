import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/trip_session.dart';
import '../../../domain/repositories/history_repository.dart';

class SaveTripUseCase {
  final HistoryRepository _repository;
  SaveTripUseCase(this._repository);

  Future<Either<Failure, void>> call(TripSession session) =>
      _repository.saveTripSession(session);
}
