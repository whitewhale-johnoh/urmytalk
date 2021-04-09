import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/providers/app_config_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:urmy_dev_client_v2/models/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:urmy_dev_client_v2/Controller/firebaseController.dart';


class AuthRepository {
  final Reader read;
  FirebaseAuth auth = FirebaseAuth.instance;

  AuthRepository({this.read});

/*
  FirebaseAuth.instance
      .authStateChanges()
      .listen((User user) {
        if (user == null) {
        print('User is currently signed out!');
        } else {
        print('User is signed in!');
        }
  });
*/
  Future<bool> login(String email, String password) async {
    //final SharedPreferences prefs = await SharedPreferences.getInstance();
    //await FirebaseAuth.instance.setPersistence(Persistence.SESSION);
    final String baseUrl = read(appConfigProvider).state.baseUrl;
    //final String url = '$baseUrl/login';
    var url = Uri.parse('$baseUrl/login');
    UrData urdata = UrData();
    UserCredential userCredential;
    var personaltokenstorage = Hive.box<UrTokenData>('tokendata');
    var personaldatastorage = Hive.box<UrData>('urmy');
    var serverdatastorage = Hive.box<KeyConfig>('keyconfig');
    final bool userdataexist = personaldatastorage.isNotEmpty;
    final bool keyconfigexist = serverdatastorage.isNotEmpty;
    print(keyconfigexist);
    /*
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }

    User user = FirebaseAuth.instance.currentUser;

    if (!user.emailVerified) {
      var actionCodeSettings = ActionCodeSettings(
          url: 'https://www.example.com/?email=${user.email}',
          dynamicLinkDomain: "example.page.link",
          androidPackageName: "com.example.urmy_dev_client_v2",
          androidInstallApp: true,
          androidMinimumVersion: "12",
          iOSBundleId: "com.example.urmyDevClientV2",
          handleCodeInApp: true);

      await user.sendEmailVerification();
    }

     */

    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
        {
          //'sessionId' : prefs.getString('sessionId'),
          'loginId': email,
          'password': password,
          'userdataexist': userdataexist,
          'serverdataexist' : keyconfigexist,
        },
      ),
    );

    if (response.statusCode != 200) {
      print('${response.statusCode}: ${response.reasonPhrase}');
      throw Exception('Fail to login');
    }

    final responseBody = jsonDecode(response.body);
    String rawCookie = response.headers['set-cookie'];
    print("rawcookie");
    print(rawCookie);
    if (rawCookie != null) {
      //int index = rawCookie.lastIndexOf("=");
      //await prefs.setString("accesstoken", rawCookie.substring(rawCookie.indexOf("accesstoken=")+12,rawCookie.indexOf("refreshtoken=")-1));
      //await prefs.setString("refreshtoken", rawCookie.substring(rawCookie.indexOf("refreshtoken=")+13,rawCookie.length));
      var tokendata = new UrTokenData();
      tokendata.accesstoken = rawCookie.substring(
          rawCookie.indexOf("accesstoken=") + 12,
          rawCookie.indexOf("refreshtoken=") - 1);
      tokendata.refreshtoken = rawCookie.substring(
          rawCookie.indexOf("refreshtoken=") + 13,
          rawCookie.length);
      //tokendata.firebasetoken = rawCookie.substring(rawCookie.indexOf("firebasetoken=") + 14, rawCookie.length);
      tokendata.firebasetoken = personaltokenstorage.get('tokendata').firebasetoken;
      personaltokenstorage.put('tokendata', tokendata);

      if(keyconfigexist == false) {
        var keyconfig = new KeyConfig();
        keyconfig.ServerKey=rawCookie.substring(
            rawCookie.indexOf("firebasekey=") + 12,
            rawCookie.indexOf("accesstoken=") - 1);
        print(keyconfig.ServerKey);
        serverdatastorage.put('firebasekey', keyconfig);
      }


      if (userdataexist == false) {
        var newurdata = new UrData();
        newurdata.email = responseBody['LoginID'];
        newurdata.email = newurdata.email.trim();
        newurdata.password = responseBody['Password'];
        newurdata.password = newurdata.password.trim();
        newurdata.nickname = responseBody['Nickname'];
        newurdata.nickname = newurdata.nickname.trim();
        newurdata.name = responseBody['Name'];
        newurdata.name = newurdata.name.trim();
        newurdata.phoneNo = responseBody['PhoneNumber'];
        newurdata.phoneNo = newurdata.phoneNo.trim();
        newurdata.genderState = responseBody['Gender'];
        try {
          await FirebaseController.instanace.updateUserToken(
              newurdata.email, tokendata.firebasetoken);
        } catch(e){
          print('token is not updated');
        }

        try {
          await FirebaseController.instanace
              .takeUserInformationFromFBDB()
              .then((documents) {
              newurdata.imageFile = documents[0]['userImageUrl'];
              urdata = newurdata;
              print(newurdata.imageFile);

          });
        } catch (e) {
          print("This is Error");
          print(e.message);
          return false;
        }

        personaldatastorage.put('urdata', urdata);
        if (personaldatastorage.isNotEmpty) {
          print("personal data saved success");
          return true;
        } else {
          throw Exception('Fail to Save Data');
        }
      } else {
        print("personal data exist");
        return true;
      }
    }

    await Future.delayed(Duration(seconds: 1));
    return false;
  }

  Future<bool> tryAutoLogin() async {
    await Future.delayed(Duration(seconds: 2));
    //final String baseUrl = read(appConfigProvider).state.baseUrl;
    // final String url = '$baseUrl/login';

    var personaldatastorage = Hive.box<UrData>('urmy');
    UrData autologin = personaldatastorage.get('urdata');

    //autologin 체크에서 email, password가 있는지 없는지 체크하기 위해 박스에서 처음에 부를 때는 정보가 없기때문에 null이 뜨고, 그걸 출력함
    if (autologin == null) {
      print("email is null");
      return false;
    } else {
      await login(autologin.email, autologin.password);

      return true;
    }
    return false;
  }

  Future<void> logout() async {}
/*
  Future<Null> _readAll() async {
    final all = await storage.readAll();
    print("all");
    print(all);
  }

  void _deleteAll() async {
    await storage.deleteAll();
    _readAll();
  }

  void _addNewItem(String tokenvalue) async {
    final String key = "accesstoken";
    final String value = tokenvalue;

    await storage.write(key: key, value: value);
    _readAll();
  }

 */
}
