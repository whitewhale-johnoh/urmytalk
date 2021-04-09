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

    return StreamBuilder<QuerySnapshot>(
        stream: friendState.userRef.collection('chatlist').snapshots(),
        builder: (context, chatlistsnapshot) {
          if (chatlistsnapshot.hasError) {
            //return error message

          }
          if (!chatlistsnapshot.hasData) {
            return CircularProgressIndicator();
          } else if (!(chatlistsnapshot.data.docs.length > 0)) {
            return Container();
          } else {
            return ListView(
              children: chatlistsnapshot.data.docs.map((data) {
                return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('userId', isEqualTo: data['chatWith'])
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, usersnapshot) {
                      if (usersnapshot.hasError) {
                        //return error message
                      }

                      if (!usersnapshot.hasData) {
                        return CircularProgressIndicator();
                      } else if (!(usersnapshot.data.docs.length > 0)) {
                        return Container();
                      } else {
                        return ListTile(
                          contentPadding: EdgeInsets.fromLTRB(10.0,5.0,5.0,5.0),
                          leading: ProfilePicture(usersnapshot),
                          title: Text(usersnapshot.data.docs[0]['name'], style: TextStyle(fontSize: 16)),
                          subtitle: Text(data['lastChat']),
                          trailing: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 4, 4),
                            child:  StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('chatroom')
                                  .doc(data['chatID'])
                                  .collection(data['chatID'])
                                  .where('idTo',isEqualTo: friendState.urdata.email)
                                  .where('isread', isEqualTo: false)
                                  .snapshots(),
                              builder: (context, notReadMSGSnapshot){
                                return Container(
                                  width: 60,
                                  height: 50,
                                  child: Column(
                                    children: <Widget>[
                                      Text(readTimestamp(data['timestamp']),style: TextStyle(fontSize: 12),),
                                      Padding(
                                          padding:const EdgeInsets.fromLTRB( 0, 5, 0, 0),
                                          child: CircleAvatar(
                                            radius: 9,
                                            child: Text(
                                                  ((notReadMSGSnapshot.hasData && notReadMSGSnapshot.data.docs.length >0) ? '${notReadMSGSnapshot.data.docs.length}' : ''),
                                              style: TextStyle(fontSize: 10),),
                                            backgroundColor: (notReadMSGSnapshot.hasData && notReadMSGSnapshot.data.docs.length >0 &&
                                                notReadMSGSnapshot.hasData && notReadMSGSnapshot.data.docs.length >0)
                                                ? Colors.red[400] : Colors.transparent,foregroundColor:Colors.white,
                                          )),
                                    ],
                                  ),
                                );
                              },
                            )
                          ),
                          onTap: (){
                            context.read(friendProvider).setCurrentFriendsData(FriendsInfo(
                              usersnapshot.data.docs[0]['FCMToken'],
                              usersnapshot.data.docs[0]['userId'],
                              usersnapshot.data.docs[0]['userImageUrl'],
                              usersnapshot.data.docs[0]['name'],
                              usersnapshot.data.docs[0]['birthdate'],
                            ));
                            context.read(friendProvider).setFriendsDetail(context
                                .read(friendProvider)
                                .state
                                .currentFriendsData
                                .friendId
                                .trim());
                            context.read(friendProvider).setChatroomSetting(
                                context.read(friendProvider).state.urdata.email,
                                context.read(friendProvider).state.currentFriendsData.friendId);
                            Navigator.pushNamed(context, UrMyChatBoardPage.routeName);
                          },
                        );
                      }
                    });
              }).toList(),
            );
          }
        });
  }

  Widget ProfilePicture(AsyncSnapshot<QuerySnapshot> snapshot) {
    String text = snapshot.data.docs[0]['userImageUrl'];
    if(text == "Not Registered" || text == null){
      return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: CircleAvatar(radius: 40, backgroundImage: AssetImage('assets/images/native_profile.png')
          )
      );
    } else {
      return ClipRRect(
          borderRadius: BorderRadius.circular(15),
        child: CachedNetworkImage(
            imageUrl: snapshot.data.docs[0]['userImageUrl'],
            alignment: Alignment.centerRight,
            width: 50,
            height: 50,
            placeholder: (context, url) => Container(
              transform: Matrix4.translationValues(0, 0, 0),
              child: Container(
                  alignment: Alignment.centerRight,
                  width: 40,
                  height: 40,
                  child: Center(child: new CircularProgressIndicator())),
            ),
            errorWidget: (context, url, error) => new Icon(Icons.error),
            fit: BoxFit.cover
        ),
      );
    }
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
