import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:urmy_dev_client_v2/models/models.dart';
import 'package:urmy_dev_client_v2/Chatting/chatboard.dart';
import 'package:urmy_dev_client_v2/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/models/urmy_friends_model.dart';
import 'package:urmy_dev_client_v2/Controller/utils.dart';

class ConcordIndexPage extends StatefulWidget {
  static const String routeName = '/friendDetail';

  @override
  _ConcordIndexPage createState() => _ConcordIndexPage();
}

class _ConcordIndexPage extends State<ConcordIndexPage> {
  final GlobalKey<FormState> _concordformKey = GlobalKey<FormState>();
  FriendsData friendsDetail;

  //final FriendsData friendsdata;
  //const ConcordIndexPage({Key key, @required this.friendsdata}) : super(key: key);
  //ConcordIndexPage(this._contact);
  //const ConcordIndexPage({Key key, @required this.contactlist}):super(key:key);
  //final Contact _contact;

  Widget buildBody(FriendState friendState) {
    if (friendState.loading){
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(
          body: Container(
            child: // Row(children: <Widget>[
            Form(
                key: _concordformKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                          decoration: InputDecoration(
                              labelText: context.read(friendProvider).state.currentFriendsData.Name
                          )),
                      TextFormField(
                          decoration: InputDecoration(
                            labelText: context.read(friendProvider).state.currentFriendsDetail.grade.toString(),
                          )),
                      TextFormField(
                          decoration: InputDecoration(
                            labelText: context.read(friendProvider).state.currentFriendsDetail.description,
                          )),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: RaisedButton(
                          onPressed: () {
                           // context.read(friendProvider).openChatting(context.read(friendProvider).state.currentFriendsDetail.yearChun);
                            //Navigator.pushNamed(context, UrMyChatBoardPage.routeName, arguments: MessagePackage(friendsdata.phones, context.read(friendProvider).state.newMessage));
                            context.read(friendProvider).setChatroomSetting(context.read(friendProvider).state.urdata.email, context.read(friendProvider).state.currentFriendsData.friendId);
                            Navigator.pushNamed(context, UrMyChatBoardPage.routeName);
                            //Navigator.pushReplacementNamed(context, UrMyChatBoardPage.routeName);
                          },
                          child: Text("Button"),
                        ),
                      )
                    ])),

          ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Friend Detail'),
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
