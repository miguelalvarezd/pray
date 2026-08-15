// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyLogAdapter extends TypeAdapter<DailyLog> {
  @override
  final typeId = 4;

  @override
  DailyLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyLog(
      date: fields[0] as String,
      completedPrayers: fields[1] == null
          ? const []
          : (fields[1] as List).cast<String>(),
      completedIntentions: fields[2] == null
          ? const []
          : (fields[2] as List).cast<String>(),
      completedNovenas: (fields[3] as List?)?.cast<String>(),
      completedActivities: (fields[4] as List?)?.cast<String>(),
      journal: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.completedPrayers)
      ..writeByte(2)
      ..write(obj.completedIntentions)
      ..writeByte(3)
      ..write(obj.completedNovenas)
      ..writeByte(4)
      ..write(obj.completedActivities)
      ..writeByte(5)
      ..write(obj.journal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
