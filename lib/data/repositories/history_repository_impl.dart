import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/local/hive_datasource_impl.dart';
import '../../domain/entities/dtc_code.dart';
import '../../domain/entities/trip_session.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HiveDataSourceImpl _dataSource;

  HistoryRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, void>> saveTripSession(TripSession session) =>
      _dataSource.saveTripSession(session);

  @override
  Future<Either<Failure, List<TripSession>>> getAllTrips() async =>
      _dataSource.getAllTrips();

  @override
  Future<Either<Failure, void>> deleteTripSession(String id) =>
      _dataSource.deleteTripSession(id);

  @override
  Future<Either<Failure, void>> saveDtcRecord(DtcCode code) =>
      _dataSource.saveDtcRecord(code);

  @override
  Future<Either<Failure, List<DtcCode>>> getRecentDtcs() async =>
      _dataSource.getRecentDtcs();

  @override
  Future<Either<Failure, void>> clearAllHistory() =>
      _dataSource.clearAllHistory();
}
