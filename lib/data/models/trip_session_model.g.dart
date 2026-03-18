// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripSessionModelAdapter extends TypeAdapter<TripSessionModel> {
  @override
  final int typeId = 0;

  @override
  TripSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripSessionModel(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime?,
      avgSpeedKmh: fields[3] as double,
      maxSpeedKmh: fields[4] as double,
      avgRpm: fields[5] as double,
      totalDistanceKm: fields[6] as double,
      totalFuelUsedL: fields[7] as double,
      avgFuelConsumptionLPer100km: fields[8] as double,
      dtcsDetected: (fields[9] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TripSessionModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.avgSpeedKmh)
      ..writeByte(4)
      ..write(obj.maxSpeedKmh)
      ..writeByte(5)
      ..write(obj.avgRpm)
      ..writeByte(6)
      ..write(obj.totalDistanceKm)
      ..writeByte(7)
      ..write(obj.totalFuelUsedL)
      ..writeByte(8)
      ..write(obj.avgFuelConsumptionLPer100km)
      ..writeByte(9)
      ..write(obj.dtcsDetected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
