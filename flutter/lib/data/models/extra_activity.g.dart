// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extra_activity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExtraActivityAdapter extends TypeAdapter<ExtraActivity> {
  @override
  final typeId = 5;

  @override
  ExtraActivity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExtraActivity(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      category: fields[3] as ActivityCategory,
    );
  }

  @override
  void write(BinaryWriter writer, ExtraActivity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtraActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
