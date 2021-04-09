import "package:flutter/material.dart";
import 'package:urmy_dev_client_v2/models/urmy_friends_model.dart';
import 'package:urmy_dev_client_v2/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/Chatting/chatboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UrMyChatListPage extends StatefulWidget {
  //const UrMyRegisterPage({Key key}) : super(key: key);
  static const String routeName = '/chatlist';

  @override
  _UrMyChatListPageState createState() => _UrMyChatListPageState();
}

class _UrMyChatListPageState extends State<UrMyChatListPage> {

  Widget buildBody(FriendState friendState) {
    if(friendState.loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    /*
    return StreamBuilder<QuerySnapshot>(
        stream: friendState.userRef.collection('friendsList').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError){
            //return error message

          }

          if (!snapshot.hasData){
            return CircularProgressIndicator();
          }
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemExtent: 100.0,
            itemBuilder: (context, index) => makeRowItem(snapshot, index, friendState),
          );
        }
    );

     */
  }


  Widget makeRowItem(FriendsData friendsdata, int index) {
    final FriendsData friendsdata = ModalRoute.of(context).settings.arguments;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder : (context) => UrMyChatBoardPage())),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
          child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: context.read(friendProvider).state.unread ? BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    border: Border.all(
                      width: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                    //shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                      )
                    ]
                  ) :
                  BoxDecoration(
                      //shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                        )
                      ]
                  ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage('assets/images/${friendsdata.email}.jpeg'),
                    )),
                Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  padding: EdgeInsets.only(left:20,),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: [
                              Text('Iron Man', style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),),
                              context.read(friendProvider).state.isOnline ?
                              Container(
                                margin: const EdgeInsets.only(left: 5),
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                                  :
                                  Container(child: null,
                                    
                                  )
                            ],
                          ),
                          Text('12:30pm', style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                            color: Colors.black54,
                          ),),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text('data of the last chat',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      ),
                    ],
                  ),
                )
              ]
          )
      ),
    );
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
