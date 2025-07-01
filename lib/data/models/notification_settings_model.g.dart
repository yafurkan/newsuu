// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationSettingsAdapter extends TypeAdapter<NotificationSettings> {
  @override
  final int typeId = 2;

  @override
  NotificationSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSettings(
      isEnabled: fields[0] as bool,
      intervalHours: fields[1] as int,
      startHour: fields[2] as int,
      endHour: fields[3] as int,
      morningEnabled: fields[4] as bool,
      afternoonEnabled: fields[5] as bool,
      eveningEnabled: fields[6] as bool,
      selectedDays: (fields[7] as List?)?.cast<int>(),
      soundEnabled: fields[8] as bool,
      vibrationEnabled: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.isEnabled)
      ..writeByte(1)
      ..write(obj.intervalHours)
      ..writeByte(2)
      ..write(obj.startHour)
      ..writeByte(3)
      ..write(obj.endHour)
      ..writeByte(4)
      ..write(obj.morningEnabled)
      ..writeByte(5)
      ..write(obj.afternoonEnabled)
      ..writeByte(6)
      ..write(obj.eveningEnabled)
      ..writeByte(7)
      ..write(obj.selectedDays)
      ..writeByte(8)
      ..write(obj.soundEnabled)
      ..writeByte(9)
      ..write(obj.vibrationEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
