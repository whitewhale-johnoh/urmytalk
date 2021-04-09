import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/models/app_config.dart';

final appConfigProvider = StateProvider<AppConfig>((ref) {
  //const String kPort = '3010';
  //final String baseUrl = 'http://10.0.2.2:$kPort';
  //final String baseUrl = 'http://192.168.10.100/app';
  // Platform.isAndroid ? 'http://10.0.2.2:$kPort' : 'http://localhost:$kPort';
  
  const String kPort = '443';
  final String baseUrl = 'https://urmytalk.urmycorp.cf:$kPort/app';


  return AppConfig(baseUrl: baseUrl);
});


/*
final chatConfigProvider = StateProvider<AppConfig>((ref) {
  const String kPort = '3010';
  final String baseUrl = 'ws://10.0.2.2:$kPort';
  // Platform.isAndroid ? 'http://10.0.2.2:$kPort' : 'http://localhost:$kPort';

  return AppConfig(baseUrl: baseUrl);
});
*/