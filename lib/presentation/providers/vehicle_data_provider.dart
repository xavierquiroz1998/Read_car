import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/vehicle_data.dart';
import 'bluetooth_provider.dart';
import 'providers.dart';

/// Live stream of vehicle data — only active when connected.
final vehicleDataProvider = StreamProvider<VehicleData>((ref) {
  final connectionState = ref.watch(connectionProvider);

  // Only stream when connected
  if (connectionState.status != ConnectionStatus.connected) {
    return Stream.value(VehicleData.empty());
  }

  final useCase = ref.watch(fetchVehicleDataUseCaseProvider);
  return useCase().map((either) {
    return either.fold(
      (failure) => throw failure,
      (data) => data,
    );
  });
});

/// Computed fuel consumption — null when vehicle is stopped.
final fuelConsumptionProvider = Provider<double?>((ref) {
  final dataAsync = ref.watch(vehicleDataProvider);
  return dataAsync.whenOrNull(data: (data) => data.fuelConsumptionLPer100km);
});
