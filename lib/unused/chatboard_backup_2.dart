import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:urmy_dev_client_v2/models/urmy_friends_model.dart';
import 'package:urmy_dev_client_v2/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/models/models.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:urmy_dev_client_v2/Controller/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UrMyChatBoardPage extends StatefulWidget {
  //const UrMyRegisterPage({Key key}) : super(key: key);
  static const String routeName = '/chatboard';

  @override
  _UrMyChatBoardState createState() => _UrMyChatBoardState();
}

class _UrMyChatBoardState extends State<UrMyChatBoardPage> {

  final formattime = new DateFormat('hh:mm a');
  final ScrollController _chatListController = ScrollController();
  final TextEditingController _msgTextController = new TextEditingController();

  //final FriendsData friendsdata = ModalRoute.of(context).settings.arguments;
  void initState() {
    super.initState();
    context.read(friendProvider).getMyData();
  }

  chatBubble(Message messages, bool isMe) {
    if (isMe) {
      return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topRight,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80,
              ),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                    )
                  ]),
              child: Text(messages.content),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                formattime.format(messages.timeofmessage),
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                  decoration: BoxDecoration(
                      //shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                        )
                      ]),
                  child: CircleAvatar(
                    radius: 15,
                    //                             backgroundImage: AssetImage('assets/images/${friendsdata.phones}.jpeg'),
                  )),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80,
              ),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                    )
                  ]),
              child: Text(messages.content),
            ),
          ),
          Row(
            children: [
              Container(
                  decoration: BoxDecoration(
                      //shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                        )
                      ]),
                  child: CircleAvatar(
                    radius: 15,
//                              backgroundImage: AssetImage('assets/images/${friendsdata.phones}.jpeg'),
                  )),
              SizedBox(
                width: 10,
              ),
              Text(
                messages.timeofmessage.toIso8601String(),
                style: TextStyle(fontSize: 12, color: Colors.black45),
              )
            ],
          ),
        ],
      );
    }
  }
/*
  _sendMessageArea(FriendState friendState) {
    //final AsyncSnapshot<QuerySnapshot> friendID = ModalRoute.of(context).settings.arguments;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: 70,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo),
            iconSize: 25,
            color: Theme.of(context).primaryColor,
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _textEditingController,
              decoration: InputDecoration.collapsed(hintText: "sendMessage"),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25,
            color: Theme.of(context).primaryColor,
            onPressed: () {

                final Message newMessage = Message();
                newMessage.isMe = true;
                //newMessage.roomname =
                newMessage.timeofmessage = DateTime.now();
                newMessage.content = _textEditingController.text;
                newMessage.receiver = context.read(friendProvider).state.currentFriendsData.friendId;
                newMessage.roomname = context.read(friendProvider).state.currentFriendsData.friendId;
                newMessage.sender = friendState.urdata.phoneNo;
                context.read(friendProvider).sendChatting(context.read(friendProvider).state.currentFriendsData.friendId, newMessage);


            },
          ),
        ],
      ),
    );
  }
*/
  Widget buildBody(FriendState friendState) {
    //final MessagePackage mspkg = ModalRoute.of(context).settings.arguments;
    var messageList = friendState.newMessage;
    var lengthOfmessage;
    if (messageList == null) {
      lengthOfmessage = 0;
    } else {
      lengthOfmessage = messageList.length;
    }
    //var lengthOfmessage = mspkg.message.length ?? 0;
    //print(lengthOfmessage);
    return Column(
      children: <Widget>[
        Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: friendState.userRef
                    .collection('chatroom')
                    .doc(friendState.currentChatroom.chatID)
                    .collection(friendState.currentChatroom.chatID)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return LinearProgressIndicator();
                  }
                  print(snapshot.data.docs.length);
                  return Stack(
                    children: <Widget>[
                      Column(children: <Widget>[
                        ListView(
                          reverse: true,
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(4.0, 10, 4, 10),
                          controller: _chatListController,
                          children: snapshot.data.docs.map((data) {
                            return data['idfrom'] ==
                                    friendState.currentChatroom.chatWithID
                                ? _listItemOther(
                                    context,
                                    friendState.currentFriendsData.Name,
                                    friendState.currentFriendsData.imageURL,
                                    data['content'],
                                    returnTimeStamp(data['timestamp']),
                                    data['type'])
                                : _listItemMine(
                                    context,
                                    data['content'],
                                    returnTimeStamp(data['timestamp']),
                                    data['isread'],
                                    data['type']);
                          }).toList(),
                        )
                      ])
                    ],
                  );
                })),
        //_sendMessageArea(friendState)
        _buildTextComposer()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        brightness: Brightness.dark,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: new Text('Chatboard'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
              icon: Icon(Icons.menu), color: Colors.white, onPressed: () {})
        ],
      ),
      body: ProviderListener<FriendState>(
        provider: friendStateProvider,
        onChange: (context, state) {
          if (state.error != null && state.error.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text(state.error),
                );
              },
            );
          }
        },
        child: Consumer(
          builder: (context, watch, child) {
            return buildBody(
              watch(friendStateProvider),
            );
          },
        ),
      ),
    );
  }

  Widget _listItemOther(BuildContext context, String name, String thumbnail,
      String message, String time, String type) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.0),
                      child: CachedNetworkImage(
                        imageUrl: thumbnail,
                        placeholder: (context, url) => Container(
                          transform: Matrix4.translationValues(0.0, 0.0, 0.0),
                          child: Container(
                              width: 60,
                              height: 60,
                              child: Center(
                                  child: new CircularProgressIndicator())),
                        ),
                        errorWidget: (context, url, error) =>
                            new Icon(Icons.error),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(name),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                          child: Container(
                            constraints:
                                BoxConstraints(maxWidth: size.width - 150),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding:
                                  EdgeInsets.all(type == 'text' ? 10.0 : 0),
                              child: Container(
                                  child: type == 'text'
                                      ? Text(
                                          message,
                                          style: TextStyle(color: Colors.black),
                                        )
                                      : _imageMessage(message)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14.0, left: 4),
                          child: Text(
                            time,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _listItemMine(BuildContext context, String message, String time,
      bool isRead, String type) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 14.0, right: 2, left: 4),
            child: Text(
              isRead ? '' : '1',
              style: TextStyle(fontSize: 12, color: Colors.yellow[900]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14.0, right: 4, left: 8),
            child: Text(
              time,
              style: TextStyle(fontSize: 12),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 4, 8),
                child: Container(
                  constraints:
                      BoxConstraints(maxWidth: size.width - size.width * 0.26),
                  decoration: BoxDecoration(
                    color:
                        type == 'text' ? Colors.green[700] : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(type == 'text' ? 10.0 : 0),
                    child: Container(
                        child: type == 'text'
                            ? Text(
                                message,
                                style: TextStyle(color: Colors.white),
                              )
                            : _imageMessage(message)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageMessage(imageUrlFromFB) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: GestureDetector(
        onTap: () {
          //Navigator.push(context, MaterialPageRoute(builder: (context) => FullPhoto(url: imageUrlFromFB)));
        },
        child: CachedNetworkImage(
          imageUrl: imageUrlFromFB,
          placeholder: (context, url) => Container(
            transform: Matrix4.translationValues(0, 0, 0),
            child: Container(
                width: 60,
                height: 80,
                child: Center(child: new CircularProgressIndicator())),
          ),
          errorWidget: (context, url, error) => new Icon(Icons.error),
          width: 60,
          height: 80,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 2.0),
              child: new IconButton(
                  icon: new Icon(
                    Icons.photo,
                    color: Colors.cyan[900],
                  ),
                  onPressed: () {
                    /*PickImageController.instance.cropImageFromFile().then((croppedFile) {
                      if (croppedFile != null) {
                        setState(() { messageType = 'image'; _isLoading = true; });
                        _saveUserImageToFirebaseStorage(croppedFile);
                      }else {
                        _showDialog('Pick Image error');
                      }
                    });*/
                  }),
            ),
            new Flexible(
              child: new TextField(
                controller: _msgTextController,
                onSubmitted: _handleSubmitted,
                decoration:
                    new InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 2.0),
              child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () {
                    context.read(friendProvider).setContentType('text');
                    _handleSubmitted(_msgTextController.text);
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmitted(String text) async {
    await context.read(friendProvider).sendMessage(text);
    FocusScope.of(context).requestFocus(FocusNode());
    _msgTextController.text = '';
  }
}
