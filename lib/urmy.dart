import 'package:urmy_dev_client_v2/Chatting/chatboard.dart';
import 'package:urmy_dev_client_v2/Friend_List/urmybook_concord_index.dart';
import 'package:urmy_dev_client_v2/models/key_config.dart';
import 'package:urmy_dev_client_v2/urmybook/urmybook.dart';
import 'package:urmy_dev_client_v2/Auth/login.dart';
import 'package:urmy_dev_client_v2/Auth/register.dart';
import 'package:urmy_dev_client_v2/Auth/register_additional.dart';
import 'package:urmy_dev_client_v2/Friend_List/urmybook_urmy_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/models/models.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() async {
  /*
  AppConfig urmyConfig = AppConfig();
  urmyConfig.openHive();
  */
  Hive.close();
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Firebase.initializeApp();
  //Hive.ignoreTypeId(103);
  Hive.registerAdapter(KeyConfigAdapter());
  Hive.registerAdapter(UrDataAdapter());
  Hive.registerAdapter(UrTokenDataAdapter());
  Hive.registerAdapter(FriendsDataAdapter());
  Hive.registerAdapter(MessagePackageAdapter());
  Hive.registerAdapter(MessageAdapter());


  await Future.delayed(Duration(seconds: 1));
  await Hive.openBox<KeyConfig>('keyconfig');
  await Hive.openBox<UrData>('urmy');
  await Hive.openBox<UrTokenData>('tokendata');
  await Hive.openBox<FriendsData>('friendsdata');
  await Hive.openBox<MessagePackage>('chatList');
  await Hive.openBox('currentChatRoom');
  /*
  if (Hive.isBoxOpen('urmy') != true) {
    await Hive.openBox<UrData>('urmy');
    print("urmybox is opend");
  }
  if (Hive.isBoxOpen('tokendata') != true) {
    await Hive.openBox<UrTokenData>('tokendata');
    print("tokendatabox is opend");
  }
  if (Hive.isBoxOpen('friendsdata') != true) {
    await Hive.openBox<FriendsData>('friendsdata');
    print("friendsdatabox is opend");
  }
  if (Hive.isBoxOpen('chatList')!= true) {
    await Hive.openBox<List<Message>>('chatList');
    print("chatlistbox is opend");
  }
  */
  runApp(
    ProviderScope(child: UrMy()),
  );
}

class UrMy extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UrMyLoginPage(),
      routes: <String, WidgetBuilder>{
        UrMyLoginPage.routeName: (context) => UrMyLoginPage(),
        UrMyBookPage.routeName: (context) => UrMyBookPage(),
        UrMyRegisterPage.routeName: (context) => UrMyRegisterPage(),
        UrMyRegisterAdditionalPage.routeName: (context) => UrMyRegisterAdditionalPage(),
        UrMyListPage.routeName: (context) => UrMyListPage(),
        ConcordIndexPage.routeName: (context) => ConcordIndexPage(),
        UrMyChatBoardPage.routeName: (context) => UrMyChatBoardPage(),
      },
    );
  }
}

/*
class UrMy extends StatefulWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home : UrMyLoginPage(),
      routes: {
        UrMyLoginPage.routeName: (context) => UrMyLoginPage(),
        UrMyBookPage.routeName: (context) => UrMyBookPage(),
        ConcordIndexPage.routeName: (context) => ConcordIndexPage(),
      },
    );
  }
}
 */
