import "package:flutter/material.dart";
import "package:urmy_dev_client_v2/Friend_List/urmybook_urmy_list.dart";
import "package:urmy_dev_client_v2/Chatting/chatlists.dart";
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/providers/providers.dart';

import 'package:hive_flutter/hive_flutter.dart';

class UrMyBookPage extends StatefulWidget {
  static const String routeName = '/urmybook';

  //const UrMyBookPage({Key key}) : super(key: key);

  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<UrMyBookPage> {

  @override
  void initState() {
    super.initState();
    context.read(friendProvider).refreshContacts();
    context.read(friendProvider).getMyData();
  }

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final List<Widget> _widgetOptions = <Widget>[
    UrMyListPage(),
    UrMyChatListPage(),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  void _onItemTapped(int index) {
    context.read(friendProvider).setCurrentIndex(index);
  }

  Widget buildBody(FriendState friendState) {
    return Center(
          child: _widgetOptions[context.read(friendProvider).state.curruentindex],
        );
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
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
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Text('Home'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business),
                title: Text('Business'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                title: Text('School'),
              ),
            ],
            currentIndex: context.read(friendProvider).state.curruentindex,
            selectedItemColor: Colors.amber[800],
            onTap: _onItemTapped,
          )
      );
  }
}
