import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/providers/providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:urmy_dev_client_v2/models/urmy_friends_model.dart';
import 'file:///D:/work/flutter_urmy_v2/urmy_dev_client_v2/lib/unused/urmybook_friend_list.dart';
import 'package:urmy_dev_client_v2/Friend_List/urmybook_concord_index.dart';

class UrMyListPage extends StatefulWidget {
  //const UrMyRegisterPage({Key key}) : super(key: key);
  static const String routeName = '/friendList';

  @override
  _UrMyListPageState createState() => _UrMyListPageState();
}

class _UrMyListPageState extends State<UrMyListPage> {
  Widget buildBody(FriendState friendState) {
    if (friendState.loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Column(
        children: [
          Row(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0,10.0,5.0,5.0),
              child: SizedBox(
                width: 60,
                height: 50,
                child:  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      alignment: Alignment.centerRight,
                      width: 50,
                      height: 50,
                      imageUrl:  friendState.urdata.imageFile,
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
                    )),

              ),
            ),
            SizedBox(width: 10),
            Text(friendState.urdata.name, style: TextStyle(fontSize: 16)),
          ]),
          StreamBuilder<QuerySnapshot>(
              stream: friendState.userRef.collection('friendsList').snapshots(),
              builder: (context, chatlistsnapshot) {
                if (chatlistsnapshot.hasError) {
                  //return error message

                }

                if (!chatlistsnapshot.hasData) {
                  return CircularProgressIndicator();
                }

                return ListView(
                  shrinkWrap: true,
                  children: chatlistsnapshot.data.docs.map((data) {
                    return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('userId', isEqualTo: data['friendId'])
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, usersnapshot) {
                          if (usersnapshot.hasError) {
                            //return error message

                          }

                          if (!usersnapshot.hasData) {
                            return CircularProgressIndicator();
                          }

                          return ListTile(
                            contentPadding: EdgeInsets.fromLTRB(10.0,5.0,5.0,5.0),
                            leading: GestureDetector(
                                child: Container(
                                    width: 60,
                                    height: 50,
                                    child: ProfilePicture(usersnapshot)
                                )
                            ),
                            title: Text(usersnapshot.data.docs[0]['name'], style: TextStyle(fontSize: 16)),
                            dense: false,
                            onTap: () {
                              context
                                  .read(friendProvider)
                                  .setCurrentFriendsData(FriendsInfo(
                                    usersnapshot.data.docs[0]['FCMToken'],
                                    usersnapshot.data.docs[0]['userId'],
                                    usersnapshot.data.docs[0]['userImageUrl'],
                                    usersnapshot.data.docs[0]['name'],
                                    usersnapshot.data.docs[0]['birthdate'],
                                  ));
                              context.read(friendProvider).setFriendsDetail(
                                  context
                                      .read(friendProvider)
                                      .state
                                      .currentFriendsData
                                      .friendId
                                      .trim());
                              Navigator.pushNamed(
                                  context, ConcordIndexPage.routeName);
                            },
                          );
                        });
                  }).toList(),
                );
              }),
        ],
      );
      return Container(width: 0.0, height: 0.0);
    }
  }

  Widget ProfilePicture(AsyncSnapshot<QuerySnapshot> snapshot) {
    String text = snapshot.data.docs[0]['userImageUrl'];
    if (text == "Not Registered" || text == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/native_profile.png')),
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

//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Friend List'),
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
}
