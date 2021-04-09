// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'urmy_friends_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FriendsDataAdapter extends TypeAdapter<FriendsData> {
  @override
  final int typeId = 55;

  @override
  FriendsData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FriendsData(
      email: fields[0] as String,
      name: fields[1] as String,
      grade: fields[2] as String,
      description: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FriendsData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.grade)
      ..writeByte(3)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendsDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
