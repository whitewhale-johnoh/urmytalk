// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'urmy_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UrDataAdapter extends TypeAdapter<UrData> {
  @override
  final int typeId = 5;

  @override
  UrData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UrData(
      email: fields[0] as String,
      password: fields[1] as String,
      nickname: fields[3] as String,
      name: fields[4] as String,
      phoneNo: fields[5] as String,
      genderState: fields[6] as bool,
      birthdate: fields[7] as String,
      intro: fields[8] as String,
      imageFile: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UrData obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.nickname)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.phoneNo)
      ..writeByte(6)
      ..write(obj.genderState)
      ..writeByte(7)
      ..write(obj.birthdate)
      ..writeByte(8)
      ..write(obj.intro)
      ..writeByte(9)
      ..write(obj.imageFile);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UrDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UrTokenDataAdapter extends TypeAdapter<UrTokenData> {
  @override
  final int typeId = 25;

  @override
  UrTokenData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UrTokenData(
      accesstoken: fields[0] as String,
      refreshtoken: fields[1] as String,
      firebasetoken: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UrTokenData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.accesstoken)
      ..writeByte(1)
      ..write(obj.refreshtoken)
      ..writeByte(2)
      ..write(obj.firebasetoken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UrTokenDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
