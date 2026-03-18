import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../entities/trip_session.dart';
import '../entities/dtc_code.dart';

abstract class HistoryRepository {
  Future<Either<Failure, void>> saveTripSession(TripSession session);
  Future<Either<Failure, List<TripSession>>> getAllTrips();
  Future<Either<Failure, void>> deleteTripSession(String id);
  Future<Either<Failure, void>> saveDtcRecord(DtcCode code);
  Future<Either<Failure, List<DtcCode>>> getRecentDtcs();
  Future<Either<Failure, void>> clearAllHistory();
}
