import "package:flutter/material.dart";
import 'package:urmy_dev_client_v2/models/urmy_friends_model.dart';
import 'package:urmy_dev_client_v2/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/Chatting/chatboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:urmy_dev_client_v2/Controller/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UrMyChatListPage extends StatefulWidget {
  //const UrMyRegisterPage({Key key}) : super(key: key);
  static const String routeName = '/chatlist';

  @override
  _UrMyChatListPageState createState() => _UrMyChatListPageState();
}

class _UrMyChatListPageState extends State<UrMyChatListPage> {
  Widget buildBody(FriendState friendState) {
    if (friendState.loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }


    return VisibilityDetector(
        key: Key("1"),
        onVisibilityChanged: ((visibility) {
          print(
              'ChatList Visibility code is ' + '${visibility.visibleFraction}');
          if (visibility.visibleFraction == 1.0) {
            context.read(friendProvider).getUnreadMSGCount();
          }
        }),
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').orderBy(
                'createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                //return error message

              }

              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              return countChatListUsers(friendState.urdata.email, snapshot) > 0
                  ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemExtent: 100.0,
                itemBuilder: (context, index) => makeRowItem(snapshot, index, friendState),
              )
                  : Container(
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.forum, color: Colors.grey[700], size: 64,),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'There are no users except you.\nPlease use other devices to chat.',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[700]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )),
              );
            }
        ));
  }

  Widget makeRowItem(AsyncSnapshot<QuerySnapshot> snapshot, int index, FriendState friendState) {

    print(index);
    snapshot.data.docs.map((data) {
      print(data.exists);
      print(data['userId']);
      if(data['userId'] == friendState.urdata.email){
        return Container();
      } else {
        print(data['userId']);
        return StreamBuilder<QuerySnapshot>(
            stream: friendState.userRef.collection('chatlist').where('chatWith', isEqualTo: data['userId']).snapshots(),
            builder: (context, chatListSnapshot) {
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: data['userImageUrl'],
                    placeholder: (context, url) => Container(
                      transform:
                      Matrix4.translationValues(0, 0, 0),
                      child : Container(width: 60, height: 80,
                      child: Center(child: new CircularProgressIndicator())),
                    ),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                    width: 60, height: 80, fit: BoxFit.cover,
                  ),
                ),
                title: Text(data['name']),
                subtitle: Text((chatListSnapshot.hasData && chatListSnapshot.data.docs.length >0)
                    ? chatListSnapshot.data.docs[index]['lastChat']
                    : data['chatWith']
                ),
                trailing: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 4, 4),
                  child: (chatListSnapshot.hasData && chatListSnapshot.data.docs.length > 0)
                    ? StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('chatroom')
                          .doc(chatListSnapshot.data.docs[index]['chatID'])
                          .collection(chatListSnapshot.data.docs[index]['chatID'])
                          .where('idTo',isEqualTo: friendState.urdata.email)
                          .where('isread', isEqualTo: false)
                          .snapshots(),
                      builder: (context,notReadMSGSnapshot) {
                        return Container(
                          width: 60,
                          height: 50,
                          child: Column(
                            children: <Widget>[
                              Text((chatListSnapshot.hasData && chatListSnapshot.data.docs.length >0)
                                  ? readTimestamp(chatListSnapshot.data.docs[0]['timestamp'])
                                  : '',style: TextStyle(fontSize: 12),
                              ),
                              Padding(
                                  padding:const EdgeInsets.fromLTRB( 0, 5, 0, 0),
                                  child: CircleAvatar(
                                    radius: 9,
                                    child: Text(
                                      (chatListSnapshot.hasData && chatListSnapshot.data.docs.length > 0)
                                          ? ((notReadMSGSnapshot.hasData && notReadMSGSnapshot.data.documents.length >0)
                                          ? '${notReadMSGSnapshot.data.documents.length}' : ''): '',
                                      style: TextStyle(fontSize: 10),),
                                    backgroundColor: (notReadMSGSnapshot.hasData && notReadMSGSnapshot.data.documents.length >0 &&
                                        notReadMSGSnapshot.hasData && notReadMSGSnapshot.data.documents.length >0)
                                        ? Colors.red[400] : Colors.transparent,foregroundColor:Colors.white,
                                  )),
                            ],
                          ),
                        );
                      })
                      : Text(''),
                ),
                onTap: (){
                _moveTochatRoom(data['FCMToken'],data['userId'],data['name'],data['userImageUrl'], data['birthdate']);
                },
              );
            }
        );
      }
    });
  }

  Future<void> _moveTochatRoom(selectedUserToken, selectedUserID,selectedUserName, selectedUserThumbnail, selectedUserBirthdate) async {
    context.read(friendProvider).setFriendsDetail(selectedUserID);
    context.read(friendProvider).setCurrentFriendsData(FriendsInfo(
      selectedUserToken,
      selectedUserID,
      selectedUserThumbnail,
      selectedUserName,
      selectedUserBirthdate,
    ));
    context.read(friendProvider).setChatroomSetting(context.read(friendProvider).state.urdata.email, context.read(friendProvider).state.currentFriendsData.friendId);
    Navigator.pushNamed(context, UrMyChatBoardPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          leading: IconButton(
              icon: Icon(Icons.menu), color: Colors.white, onPressed: () {}),
          title: new Text('Chatlist'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            )
          ]),
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
}
