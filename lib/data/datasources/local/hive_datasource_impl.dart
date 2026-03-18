import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/hive_boxes.dart';
import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../models/dtc_model.dart';
import '../../models/trip_session_model.dart';
import '../../../domain/entities/dtc_code.dart';
import '../../../domain/entities/trip_session.dart';

class HiveDataSourceImpl {
  Box<TripSessionModel> get _tripBox =>
      Hive.box<TripSessionModel>(HiveBoxes.tripSession);

  Box<DtcModel> get _dtcBox => Hive.box<DtcModel>(HiveBoxes.dtcHistory);

  // ── Trip sessions ─────────────────────────────────────────────────────────

  Future<Either<Failure, void>> saveTripSession(TripSession session) async {
    try {
      await _tripBox.put(session.id, TripSessionModel.fromEntity(session));
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  Either<Failure, List<TripSession>> getAllTrips() {
    try {
      final trips = _tripBox.values
          .map((m) => m.toEntity())
          .toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
      return Right(trips);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteTripSession(String id) async {
    try {
      await _tripBox.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  // ── DTC records ───────────────────────────────────────────────────────────

  Future<Either<Failure, void>> saveDtcRecord(DtcCode code) async {
    try {
      final key = '${code.code}_${code.detectedAt.millisecondsSinceEpoch}';
      await _dtcBox.put(key, DtcModel.fromEntity(code));

      // Trim to max entries
      if (_dtcBox.length > AppConstants.maxHistoryEntries) {
        final oldest = _dtcBox.keys.first;
        await _dtcBox.delete(oldest);
      }
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  Either<Failure, List<DtcCode>> getRecentDtcs() {
    try {
      final dtcs = _dtcBox.values
          .map((m) => m.toEntity())
          .toList()
        ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
      return Right(dtcs);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> clearAllHistory() async {
    try {
      await _tripBox.clear();
      await _dtcBox.clear();
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }
}
