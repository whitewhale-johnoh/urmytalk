// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 105;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      roomname: fields[0] as String,
      isMe: fields[1] as bool,
      sender: fields[2] as String,
      receiver: fields[3] as String,
      content: fields[4] as String,
      timeofmessage: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.roomname)
      ..writeByte(1)
      ..write(obj.isMe)
      ..writeByte(2)
      ..write(obj.sender)
      ..writeByte(3)
      ..write(obj.receiver)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.timeofmessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessagePackageAdapter extends TypeAdapter<MessagePackage> {
  @override
  final int typeId = 75;

  @override
  MessagePackage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessagePackage(
      message: (fields[0] as List)?.cast<Message>(),
    );
  }

  @override
  void write(BinaryWriter writer, MessagePackage obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.message);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessagePackageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
