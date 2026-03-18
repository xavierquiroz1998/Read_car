import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/trip_session.dart';
import 'providers.dart';

class HistoryNotifier extends AsyncNotifier<List<TripSession>> {
  @override
  Future<List<TripSession>> build() async {
    final result = await ref.read(getTripsUseCaseProvider).call();
    return result.fold((_) => [], (trips) => trips);
  }

  Future<void> saveTrip(TripSession session) async {
    await ref.read(saveTripsUseCaseProvider).call(session);
    ref.invalidateSelf();
  }

  Future<void> reload() async => ref.invalidateSelf();
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<TripSession>>(
  HistoryNotifier.new,
);
