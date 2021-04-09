import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:urmy_dev_client_v2/models/urmy_friends_model.dart';
import 'package:urmy_dev_client_v2/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/models/models.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:urmy_dev_client_v2/Controller/utils.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UrMyChatBoardPage extends StatefulWidget {
  //const UrMyRegisterPage({Key key}) : super(key: key);
  static const String routeName = '/chatboard';

  @override
  _UrMyChatBoardState createState() => _UrMyChatBoardState();
}

class _UrMyChatBoardState extends State<UrMyChatBoardPage>
    with TickerProviderStateMixin {
  //_UrMyChatBoardState({this.animationController});
  final formattime = new DateFormat('hh:mm a');
  final ScrollController _chatListController = ScrollController();
  final TextEditingController _msgTextController = new TextEditingController();
  //final FocusNode focusNode = FocusNode();

  // final AnimationController animationController;
  double _scrollPosition = 560;
  int chatListLength = 20;

  //final FriendsData friendsdata = ModalRoute.of(context).settings.arguments;
  void initState() {
    //focusNode.addListener(onFocusChange);
    context.read(friendProvider).getMyData();
    context.read(friendProvider).getUnreadMSGCount();
    _chatListController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
/*
  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      context.read(friendProvider).onFocusChange();
    }
  }
*/
  void getSticker() {
    // Hide keyboard when sticker appear
    //focusNode.unfocus();
    context.read(friendProvider).getSticker();
  }

  _scrollListener() {
    setState(() {
      if (_scrollPosition < _chatListController.position.pixels) {
        _scrollPosition = _scrollPosition + 560;
        chatListLength = chatListLength + 20;
      }
     _scrollPosition = _chatListController.position.pixels;
      print('list view position is $_scrollPosition');
    });
  }

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
    return VisibilityDetector(
      key: Key("1"),
      onVisibilityChanged: ((visibility) {
        print(visibility.visibleFraction);
        if (visibility.visibleFraction == 1.0) {
          context.read(friendProvider).getUnreadMSGCount();
        }
      }),
      child: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chatroom')
                    .doc(friendState.currentChatroom.chatID)
                    .collection(friendState.currentChatroom.chatID)
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return LinearProgressIndicator();
                  }
                  if (snapshot.hasData) {
                    for (var data in snapshot.data.docs) {
                      if (data['idTo'] == friendState.urdata.email &&
                          data['isread'] == false) {
                        if (data.reference != null) {
                          FirebaseFirestore.instance.runTransaction(
                              (Transaction myTransaction) async {
                            await myTransaction
                                .update(data.reference, {'isread': true});
                          });
                        }
                      }
                    }
                  }
                  return ListView.separated(
                      reverse: true,
                      controller: _chatListController,
                      scrollDirection: Axis.vertical,
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) =>
                          makeRowItem(snapshot, index, friendState),
                    separatorBuilder: (context, index) => makeDateSeperated(snapshot, index),
                  );

                }),
          ),
          //_sendMessageArea(friendState)
          _buildTextComposer()
        ],
      ),
    );
  }

  Widget makeDateSeperated(AsyncSnapshot<QuerySnapshot> snapshot, int index) {
    if(index == 0){
      return Container();
    }
    index = snapshot.data.docs.length - 1 - index;
    int previoustimevalue = snapshot.data.docs[index - 1]['timestamp'];
    int currenttimevalue = snapshot.data.docs[index]['timestamp'];
    if ((previoustimevalue / 86400000).floor() !=
        (currenttimevalue / 86400000).floor()) {
      return Container(
        alignment: Alignment.center,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.80,
          ),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                )
              ]),
          child: Text(returnDateStamp(currenttimevalue), style: TextStyle(fontSize: 20)),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget makeRowItem(AsyncSnapshot<QuerySnapshot> snapshot, int index,
      FriendState friendState) {
    index = snapshot.data.docs.length - 1 - index;

    if (index == snapshot.data.docs.length - 1 || index == 0) {
      return snapshot.data.docs[index]['idFrom'] ==
              friendState.currentChatroom.chatWithID
          ? _listItemOther(
              context,
              friendState.currentFriendsData.Name,
              friendState.currentFriendsData.imageURL,
              snapshot.data.docs[index]['content'],

              returnTimeStamp(snapshot.data.docs[index]['timestamp']),
              snapshot.data.docs[index]['type'],
              )
          : _listItemMine(
              context,
              snapshot.data.docs[index]['content'],

          returnTimeStamp(snapshot.data.docs[index]['timestamp']),
              snapshot.data.docs[index]['isread'],
              snapshot.data.docs[index]['type'],
                            );
    } else {
      int currenttimevalue = snapshot.data.docs[index]['timestamp'];
      int nexttimevalue = snapshot.data.docs[index + 1]['timestamp'];
      if (snapshot.data.docs[index]['idFrom'] ==
          friendState.currentChatroom.chatWithID) {
        if ((snapshot.data.docs[index + 1]['idFrom'] ==
            friendState.currentChatroom.chatWithID)) {
          if ((nexttimevalue / 60000).floor() ==
              (currenttimevalue / 60000).floor()) {
            return _listItemOther(
                context,
                friendState.currentFriendsData.Name,
                friendState.currentFriendsData.imageURL,
                snapshot.data.docs[index]['content'],

                '',
                snapshot.data.docs[index]['type'],
                );
          }
        }
        return _listItemOther(
            context,
            friendState.currentFriendsData.Name,
            friendState.currentFriendsData.imageURL,
            snapshot.data.docs[index]['content'],

            returnTimeStamp(snapshot.data.docs[index]['timestamp']),
            snapshot.data.docs[index]['type'],
            );
      } else {
        if (snapshot.data.docs[index + 1]['idFrom'] !=
            friendState.currentChatroom.chatWithID) {
          if ((nexttimevalue / 60000).floor() ==
              (currenttimevalue / 60000).floor()) {
            return _listItemMine(
                context,
                snapshot.data.docs[index]['content'],
                '',
                snapshot.data.docs[index]['isread'],
                snapshot.data.docs[index]['type'],
                              );
          }
        }
        return _listItemMine(
            context,
            snapshot.data.docs[index]['content'],

            returnTimeStamp(snapshot.data.docs[index]['timestamp']),
            snapshot.data.docs[index]['isread'],
            snapshot.data.docs[index]['type'],
                      );
      }
    }
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
      return Padding(
        padding: const EdgeInsets.only(top: 4.0, left: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                alignment: Alignment.centerRight,
                width: 50,
                height: 50,
                imageUrl: thumbnail,
                placeholder: (context, url) => Container(
                  transform: Matrix4.translationValues(0, 0, 0),
                  child: Container(
                      alignment: Alignment.centerRight,
                      width: 40,
                      height: 40,
                      child: Center(child: new CircularProgressIndicator())),
                ),
                errorWidget: (context, url, error) => new Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Container(
              alignment: Alignment.centerLeft,
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
                child: Text(message, style: TextStyle(fontSize: 20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 4, left: 8, top: 40),
              child: Text(
                time,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );

  }

  Widget _listItemMine(BuildContext context, String message, String time,
      bool isRead, String type) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0, right: 2, left: 4),
              child: Text(
                isRead ? '' : '1',
                style: TextStyle(fontSize: 12, color: Colors.yellow[900]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0, right: 4, left: 8),
              child: Text(
                time,
                style: TextStyle(fontSize: 12),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
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
                child: Text(
                  message,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            )
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
                //focusNode: focusNode,
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 2.0),
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoButton(
                      child: Text('Send'),
                      onPressed: () {
                        context.read(friendProvider).setContentType('text');
                        _msgTextController.text.length > 0
                            ? _handleSubmitted(_msgTextController.text)
                            : null;
                      })
                  : new IconButton(
                      icon: new Icon(Icons.send),
                      onPressed: () {
                        context.read(friendProvider).setContentType('text');
                        _msgTextController.text.length > 0
                            ? _handleSubmitted(_msgTextController.text)
                            : null;
                      }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmitted(String text) async {
    await context.read(friendProvider).sendMessage(text);
    _resetTextFieldAndLoading();
  }

  _resetTextFieldAndLoading() {
    _msgTextController.text = '';
    //FocusScope.of(context).requestFocus(focusNode);
    //_UrMyChatBoardState urmychatboard = _UrMyChatBoardState(animationController: AnimationController(duration: const Duration(milliseconds: 700), vsync: this));
    //urmychatboard.animationController.forward();
  }
}
