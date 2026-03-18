import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/trip_session.dart';
import '../../../domain/repositories/history_repository.dart';

class GetTripsUseCase {
  final HistoryRepository _repository;
  GetTripsUseCase(this._repository);

  Future<Either<Failure, List<TripSession>>> call() =>
      _repository.getAllTrips();
}
