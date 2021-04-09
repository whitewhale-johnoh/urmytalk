import 'package:hive/hive.dart';

part 'message_model.g.dart';


@HiveType(typeId: 105)
class Message {
  @HiveField(0)
  String roomname;
  @HiveField(1)
  bool isMe;
  @HiveField(2)
  String sender;
  @HiveField(3)
  String receiver;
  @HiveField(4)
  String content;
  @HiveField(5)
  DateTime timeofmessage;

  Message({
    this.roomname,
    this.isMe,
    this.sender,
    this.receiver,
    this.content,
    this.timeofmessage
  });
}

@HiveType(typeId: 75)
class MessagePackage  extends HiveObject {

  @HiveField(0)
  List<Message> message;

  MessagePackage({
    this.message,
  });
}

class Chatroom {
  String chatID;
  String chatWithID;
}

