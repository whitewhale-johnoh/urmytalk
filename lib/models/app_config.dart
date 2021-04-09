import 'package:meta/meta.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';

class AppConfig {
  String baseUrl;
//  String buildFlavor;

  AppConfig({
    @required this.baseUrl,
  //  @required this.buildFlavor,
  });

  void openHive() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    await Hive.openBox('urmy');
    await Hive.openBox('tokendata');
  }
}
