// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intention_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IntentionStatusAdapter extends TypeAdapter<IntentionStatus> {
  @override
  final typeId = 6;

  @override
  IntentionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IntentionStatus.active;
      case 1:
        return IntentionStatus.archived;
      case 2:
        return IntentionStatus.answered;
      default:
        return IntentionStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, IntentionStatus obj) {
    switch (obj) {
      case IntentionStatus.active:
        writer.writeByte(0);
      case IntentionStatus.archived:
        writer.writeByte(1);
      case IntentionStatus.answered:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntentionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
