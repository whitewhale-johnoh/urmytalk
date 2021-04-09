import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:urmy_dev_client_v2/providers/app_config_provider.dart';

class RegisterAdditionalRepository {
  final Reader read;

  RegisterAdditionalRepository({this.read});

  Future<void> registerAdditional(String birthdate) async {
    final String baseUrl = read(appConfigProvider).state.baseUrl;

    //  final String buildFlavor = read(appConfigProvider).state.buildFlavor;

    final String url = '$baseUrl/registeradditional';

    await Future.delayed(Duration(seconds: 2));
    print("accesstoken2");

    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
       // 'Authorization' : prefs.getString('accesstoken')
      },
      body: json.encode(
        {

          'birthdate': birthdate,
        },
      ),
    );

    if (response.statusCode != 200) {
      //     if (buildFlavor == 'dev') {
      print('${response.statusCode}: ${response.reasonPhrase}');
      //     }
      throw Exception('Fail to register');
    }

    final responseBody = json.decode(response.body);
    /*
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.lastIndexOf("=");
      await prefs.setString("accesstoken", rawCookie.substring(index+1,rawCookie.length));
    }
    print("accesstoken3");
    print(prefs.getString("accesstoken"));
     */

 /*   _sessionId = responseBody['sessionId'];

    if (_sessionId != prefs.getString('sessionId')) {
      await prefs.setString('sessionId', _sessionId);
    }
    */
    //_birthdate = responseBody['birthdate'];

    //    final token = responseBody['token'];

    //   if (buildFlavor == 'dev') {
    //     print('token: $token');
    //  }
  }
}
