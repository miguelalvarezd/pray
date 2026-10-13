// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityCategoryAdapter extends TypeAdapter<ActivityCategory> {
  @override
  final typeId = 1;

  @override
  ActivityCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActivityCategory.sacramental;
      case 1:
        return ActivityCategory.devotional;
      case 2:
        return ActivityCategory.service;
      case 3:
        return ActivityCategory.spiritual;
      default:
        return ActivityCategory.sacramental;
    }
  }

  @override
  void write(BinaryWriter writer, ActivityCategory obj) {
    switch (obj) {
      case ActivityCategory.sacramental:
        writer.writeByte(0);
      case ActivityCategory.devotional:
        writer.writeByte(1);
      case ActivityCategory.service:
        writer.writeByte(2);
      case ActivityCategory.spiritual:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
