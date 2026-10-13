// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novena.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NovenaAdapter extends TypeAdapter<Novena> {
  @override
  final typeId = 3;

  @override
  Novena read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Novena(
      id: fields[0] as String,
      title: fields[1] as String,
      intentionId: fields[7] as String?,
      startDate: fields[3] as String,
      createdAt: fields[4] as String,
      prayer: fields[5] as String?,
      templateId: fields[6] as String?,
      legacyIntentionText: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Novena obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.legacyIntentionText)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.prayer)
      ..writeByte(6)
      ..write(obj.templateId)
      ..writeByte(7)
      ..write(obj.intentionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NovenaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
