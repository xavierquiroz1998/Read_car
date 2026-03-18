import 'package:equatable/equatable.dart';

/// Summary of a driving session persisted to local storage.
class TripSession extends Equatable {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final double avgSpeedKmh;
  final double maxSpeedKmh;
  final double avgRpm;
  final double totalDistanceKm;
  final double totalFuelUsedL;
  final double avgFuelConsumptionLPer100km;
  final List<String> dtcsDetected;

  const TripSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.avgSpeedKmh,
    required this.maxSpeedKmh,
    required this.avgRpm,
    required this.totalDistanceKm,
    required this.totalFuelUsedL,
    required this.avgFuelConsumptionLPer100km,
    this.dtcsDetected = const [],
  });

  Duration get duration =>
      (endTime ?? DateTime.now()).difference(startTime);

  @override
  List<Object?> get props => [id, startTime];
}
