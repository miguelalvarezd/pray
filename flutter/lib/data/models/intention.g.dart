// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intention.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IntentionAdapter extends TypeAdapter<Intention> {
  @override
  final typeId = 2;

  @override
  Intention read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Intention(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      createdAt: fields[3] as String,
      targetDate: fields[4] as String?,
      priority: fields[5] as Priority,
      isArchived: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Intention obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.targetDate)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.isArchived);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntentionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
