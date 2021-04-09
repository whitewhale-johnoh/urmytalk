// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KeyConfigAdapter extends TypeAdapter<KeyConfig> {
  @override
  final int typeId = 3;

  @override
  KeyConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KeyConfig(
      ServerKey: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, KeyConfig obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.ServerKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
