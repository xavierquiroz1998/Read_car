// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dtc_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DtcModelAdapter extends TypeAdapter<DtcModel> {
  @override
  final int typeId = 1;

  @override
  DtcModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DtcModel(
      code: fields[0] as String,
      description: fields[1] as String,
      severityLabel: fields[2] as String,
      detectedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DtcModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.severityLabel)
      ..writeByte(3)
      ..write(obj.detectedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DtcModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
