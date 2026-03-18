import 'package:equatable/equatable.dart';

/// Immutable snapshot of all live OBD2 readings at a given moment.
class VehicleData extends Equatable {
  final int speedKmh;
  final double rpm;
  final int coolantTempC;
  final double fuelLevelPercent;
  final double engineLoadPercent;
  final double? fuelConsumptionLPer100km; // null when speed == 0
  final DateTime timestamp;

  const VehicleData({
    required this.speedKmh,
    required this.rpm,
    required this.coolantTempC,
    required this.fuelLevelPercent,
    required this.engineLoadPercent,
    this.fuelConsumptionLPer100km,
    required this.timestamp,
  });

  /// Empty / zero-initialised state shown before first poll.
  factory VehicleData.empty() => VehicleData(
        speedKmh: 0,
        rpm: 0,
        coolantTempC: 0,
        fuelLevelPercent: 0,
        engineLoadPercent: 0,
        fuelConsumptionLPer100km: null,
        timestamp: DateTime.now(),
      );

  VehicleData copyWith({
    int? speedKmh,
    double? rpm,
    int? coolantTempC,
    double? fuelLevelPercent,
    double? engineLoadPercent,
    double? fuelConsumptionLPer100km,
    DateTime? timestamp,
  }) {
    return VehicleData(
      speedKmh: speedKmh ?? this.speedKmh,
      rpm: rpm ?? this.rpm,
      coolantTempC: coolantTempC ?? this.coolantTempC,
      fuelLevelPercent: fuelLevelPercent ?? this.fuelLevelPercent,
      engineLoadPercent: engineLoadPercent ?? this.engineLoadPercent,
      fuelConsumptionLPer100km:
          fuelConsumptionLPer100km ?? this.fuelConsumptionLPer100km,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
        speedKmh,
        rpm,
        coolantTempC,
        fuelLevelPercent,
        engineLoadPercent,
        fuelConsumptionLPer100km,
        timestamp,
      ];
}
