import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/models/models.dart';
import 'package:urmy_dev_client_v2/providers/app_config_provider.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:hive/hive.dart';
import 'package:urmy_dev_client_v2/urmy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io' show WebSocket;
import 'package:urmy_dev_client_v2/models/urmy_model.dart';
import 'package:urmy_dev_client_v2/providers/app_config_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
//import 'package:websocket/websocket.dart';
import 'package:web_socket_channel/status.dart' as status;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:urmy_dev_client_v2/Controller/firebaseController.dart';
import 'package:urmy_dev_client_v2/Controller/notificationControllers.dart';


class FriendRepository {
  final Reader read;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();



  FriendRepository({this.read});
/*
  Future<void> connectToMQTTServer() async {
    final String baseUrl = read(chatConfigProvider).state.baseUrl;
    final String url = '$baseUrl/friendchat';
    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',

      },
    );
    print(response.body);


    channel = IOWebSocketChannel.connect('ws://echo.websocket.org');
    channel.stream.listen((message){
      channel.sink.add('received!');
      channel.sink.close(status.goingAway);
    });
    //print(channel);
    var personaltokenstorage = Hive.box<UrTokenData>('tokendata');
    var friendstorage = Hive.box<FriendsData>('friendsdata');


    HttpClient client = HttpClient();
    HttpClientRequest request = await client.get('10.0.2.2', 3010, '/friendchat');
    HttpClientResponse response = await request.close();
    Socket socket = await response.detachSocket();

  }
 */



  Future<List<FriendsData>> refreshContacts() async {
    Iterable<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: false);
    List<Contact> contactsList = contacts.toList();
    List _contactMaps = contactsList.map((e) => e.toMap()).toList();
    _contactMaps.forEach((element) {
      element.remove("middleName");
      element.remove("displayName");
      element.remove("prefix");
      element.remove("suffix");
      element.remove("company");
      element.remove("jobTitle");
      element.remove("androidAccountType");
      element.remove("androidAccountName");
      element.remove("emails");
      element.remove("postalAddresses");
      element.remove("avatar");
      element.remove("birthday");
    });

    final String baseUrl = read(appConfigProvider).state.baseUrl;
    //final channel = IOWebSocketChannel.connect('ws://$baseUrl/chatchannel');
    var url = Uri.parse('$baseUrl/friendlist');
    var personaldatastorage = Hive.box<UrData>('urmy');
    var personaltokenstorage = Hive.box<UrTokenData>('tokendata');
    var friendstorage = Hive.box<FriendsData>('friendsdata');

    //   await Future.delayed(Duration(seconds: 2));

    List<Map<dynamic,dynamic>> friendsrawdata = [];
    for (var friend in _contactMaps) {
      //탈퇴자가 있을 수 있기에 일단 전체 전화번호를 다 조회
      friendsrawdata.add(FriendsRawData.fromJson(friend).toJSON());
    }




    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'AuthorizationAccess': personaltokenstorage.get('tokendata').accesstoken,
        'AuthorizationRefresh': personaltokenstorage.get('tokendata').refreshtoken
      },
      body: jsonEncode(friendsrawdata),
    );

    if (response.statusCode != 200) {
      print('${response.statusCode}: ${response.reasonPhrase}');
      throw Exception('Fail to getFriendList');
    }
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      //int index = rawCookie.lastIndexOf("=");
      //await prefs.setString("accesstoken", rawCookie.substring(rawCookie.indexOf("accesstoken=")+12,rawCookie.indexOf("refreshtoken=")-1));
      //await prefs.setString("refreshtoken", rawCookie.substring(rawCookie.indexOf("refreshtoken=")+13,rawCookie.length));
      var tokendata = UrTokenData();
      tokendata.accesstoken = rawCookie.substring(
          rawCookie.indexOf("accesstoken=") + 12,
          rawCookie.indexOf("refreshtoken=") - 1);
      tokendata.refreshtoken = rawCookie.substring(
          rawCookie.indexOf("refreshtoken=") + 13, rawCookie.length);
      personaltokenstorage.put('tokendata',tokendata);
    }
    final friends = json.decode(response.body);
    print(response.body);
    //await Future.delayed(Duration(seconds: 1));
    List<FriendsData> friendsMap = [];
    for (var friend in friends) {
      if (FriendsData.fromJson(friend).email != '') {
        friendstorage.put(FriendsData.fromJson(friend).email.trim(), FriendsData.fromJson(friend));
      }
    }
    for (var friend in friendstorage.values){
      friendsMap.add(friend);
      await FirebaseController.instanace.saveFriendData(personaldatastorage.get('urdata').email.trim(), friend.email.trim());
    }
    return friendsMap;
  }
  /*
  Future<Stream<QuerySnapshot>> syncWithFBDB(List<FriendsData> friendsMap) async {
    Stream<QuerySnapshot> friendsdocumentList;
    for(var friend in friendsMap) {
      var frienddocument = await FirebaseController.instanace.takeFriendsInformationFromFBDB(friend.email);
      if(frienddocument.isNotEmpty) {
        friendsdocumentList.join(frienddocument);
      }
     }
    return friendsdocumentList;
  }
  */
  Future<UrData> getMyData() async {
    var mydataBox = Hive.box<UrData>('urmy');
    UrData getMyData = mydataBox.get('urdata');
    UrData urdata = new UrData();
    urdata.email = getMyData.email;
    urdata.phoneNo = getMyData.phoneNo;
    urdata.nickname = getMyData.nickname;
    urdata.name = getMyData.name;
    urdata.imageFile = getMyData.imageFile;
    urdata.birthdate = getMyData.birthdate;
    return urdata;
  }

  Future<FriendsData> getFriendDetail(String friendId) async{
    var friendstorage = Hive.box<FriendsData>('friendsdata');
    FriendsData getFriendsData = friendstorage.get(friendId);
    return getFriendsData;
  }



  Future<List<Message>> openChatting(String phones) async {
    //print(phones);
    //print(phones.length);
    print('tryopenchat');

    var messageBox = Hive.box<MessagePackage>('chatList');
    if(messageBox.get(phones) == null){
      MessagePackage newMessagePackage = new MessagePackage();
      newMessagePackage.message = [];
      messageBox.put(phones, newMessagePackage);
    }
    List<Message> storedmessage = messageBox.get(phones).message;
    //print("openchat");
    //print(phones);
    return storedmessage;
  }

  Future<void> sendChatting(String chatID, String myID, String selectedUserID, String content, String messageType, String myName, String selectedUserToken) async{
    await FirebaseController.instanace.sendMessageToChatRoom(chatID, myID, selectedUserID, content, messageType);
    await FirebaseController.instanace.updateChatRequestField(selectedUserID, messageType == 'text' ? content : '(Photo)', chatID, myID, selectedUserID);
    await FirebaseController.instanace.updateChatRequestField(myID, messageType == 'text' ? content : '(Photo)', chatID, myID, selectedUserID);
    await _getUnreadMSGCountThenSendMessage(selectedUserID, messageType, content, myName, chatID, selectedUserToken);
  }

  Future<void> getUnreadMSGCount() async{
    await FirebaseController.instanace.getUnreadMSGCount();
  }

  Future<void> _getUnreadMSGCountThenSendMessage(String selectedID, String messageType, String content, String myName, String chatID, String selectedUserToken) async{
    try {
      int unReadMSGCount = await FirebaseController.instanace.getUnreadMSGCount(selectedID);
      await NotificationController.instance.sendNotificationMessageToPeerUser(unReadMSGCount, messageType, content, myName, chatID, selectedUserToken);
    }catch(e) {
      print(e.message);
    }
  }

  /*
  Future<List<Message>> sendChatting(String friendID, Message message) async {

    if(Hive.isBoxOpen('chatList') != true){
      Hive.openBox<MessagePackage>('chatList');
    }
    //print(phones);
    var personaldatastorage = Hive.box<UrData>('urmy');
    var messageBox = Hive.box<MessagePackage>('chatList');
    MessagePackage storedmessage = messageBox.get(friendID);
    storedmessage.message.add(message);

    messageBox.put(friendID, storedmessage);
    //print(messages[messages.length].content);
    /*await FirebaseController.instanace.sendMessageToChatRoom(widget.chatID,widget.myID,widget.selectedUserID,text,messageType);
    await FirebaseController.instanace.updateChatRequestField(widget.selectedUserID, messageType == 'text' ? text : '(Photo)',widget.chatID,widget.myID,widget.selectedUserID);
    await FirebaseController.instanace.updateChatRequestField(widget.myID, messageType == 'text' ? text : '(Photo)',widget.chatID,widget.myID,widget.selectedUserID);
     */
    return storedmessage.message;
  }

   */
}
