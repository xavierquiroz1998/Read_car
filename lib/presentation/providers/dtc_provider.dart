import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dtc_code.dart';
import 'providers.dart';

class DtcNotifier extends AsyncNotifier<List<DtcCode>> {
  @override
  Future<List<DtcCode>> build() async => [];

  Future<void> readDtcs() async {
    state = const AsyncLoading();
    final result = await ref.read(readDtcUseCaseProvider).call();
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (codes) => AsyncData(codes),
    );
  }

  Future<bool> clearDtcs() async {
    final result = await ref.read(clearDtcUseCaseProvider).call();
    return result.fold(
      (_) => false,
      (_) {
        state = const AsyncData([]);
        return true;
      },
    );
  }
}

final dtcProvider = AsyncNotifierProvider<DtcNotifier, List<DtcCode>>(
  DtcNotifier.new,
);
