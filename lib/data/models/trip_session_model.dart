import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/hive_boxes.dart';
import '../../domain/entities/trip_session.dart';

part 'trip_session_model.g.dart';

@HiveType(typeId: HiveTypeIds.tripSession)
class TripSessionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final DateTime? endTime;

  @HiveField(3)
  final double avgSpeedKmh;

  @HiveField(4)
  final double maxSpeedKmh;

  @HiveField(5)
  final double avgRpm;

  @HiveField(6)
  final double totalDistanceKm;

  @HiveField(7)
  final double totalFuelUsedL;

  @HiveField(8)
  final double avgFuelConsumptionLPer100km;

  @HiveField(9)
  final List<String> dtcsDetected;

  TripSessionModel({
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

  factory TripSessionModel.fromEntity(TripSession e) => TripSessionModel(
        id: e.id,
        startTime: e.startTime,
        endTime: e.endTime,
        avgSpeedKmh: e.avgSpeedKmh,
        maxSpeedKmh: e.maxSpeedKmh,
        avgRpm: e.avgRpm,
        totalDistanceKm: e.totalDistanceKm,
        totalFuelUsedL: e.totalFuelUsedL,
        avgFuelConsumptionLPer100km: e.avgFuelConsumptionLPer100km,
        dtcsDetected: List.from(e.dtcsDetected),
      );

  TripSession toEntity() => TripSession(
        id: id,
        startTime: startTime,
        endTime: endTime,
        avgSpeedKmh: avgSpeedKmh,
        maxSpeedKmh: maxSpeedKmh,
        avgRpm: avgRpm,
        totalDistanceKm: totalDistanceKm,
        totalFuelUsedL: totalFuelUsedL,
        avgFuelConsumptionLPer100km: avgFuelConsumptionLPer100km,
        dtcsDetected: List.from(dtcsDetected),
      );
}
