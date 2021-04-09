import "package:flutter/material.dart";
import 'package:urmy_dev_client_v2/models/urmy_friends_model.dart';
import 'package:urmy_dev_client_v2/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/models/models.dart';


class UrMyChatBoardPage extends StatefulWidget {
  //const UrMyRegisterPage({Key key}) : super(key: key);
  static const String routeName = '/chatboard';

  @override
  _UrMyChatBoardState createState() => _UrMyChatBoardState();
}

class _UrMyChatBoardState extends State<UrMyChatBoardPage> {

  //final FriendsData friendsdata = ModalRoute.of(context).settings.arguments;
  void initState() {
    super.initState();
  }

  chatBubble(Message messages, bool isMe) {
    if(isMe) {
      return Column(
        children: <Widget>[
          Container(
            alignment:Alignment.topRight,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80,
              ),
              padding:EdgeInsets.all(10),
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
                  ]
              ),
              child: Text('data1'),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('12:30pm', style: TextStyle(fontSize: 12, color: Colors.black45),),
              SizedBox(width: 10,),
              Container(
                  decoration: BoxDecoration(
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
            alignment:Alignment.topLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80,
              ),
              padding:EdgeInsets.all(10),
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
                  ]
              ),
              child: Text('data'),
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
                      ]
                  ),
                  child: CircleAvatar(
                    radius: 15,
//                              backgroundImage: AssetImage('assets/images/${friendsdata.phones}.jpeg'),
                  )),
              SizedBox(width: 10,),
              Text('12:30pm', style: TextStyle(fontSize: 12, color: Colors.black45),)
            ],
          ),
        ],
      );
    }
  }

  _sendMessageArea() {
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
              decoration: InputDecoration.collapsed(hintText: "sendMessage"),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25,
            color: Theme.of(context).primaryColor,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget buildBody(FriendState friendState) {
    final List<Message> messageList = ModalRoute.of(context).settings.arguments;
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: messageList.length,
            itemBuilder: (BuildContext context, int index ){
              final Message message = messageList[index];
              //final bool isMe = message.sender.id == currentUser.id;
              return chatBubble(message, message.isMe);
              //return chatBubble(message, isMe);
            },
          ),
        ),
        _sendMessageArea()
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
          onPressed: (){
          Navigator.pop(context);
        },),
        title: new Text('Chatboard'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
              icon: Icon(Icons.menu),
              color: Colors.white,
              onPressed: () {}
          )
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
}