import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:urmy_dev_client_v2/Auth/register.dart';
import 'package:urmy_dev_client_v2/providers/app_config_provider.dart';
import 'package:urmy_dev_client_v2/models/urmy_model.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:urmy_dev_client_v2/Controller/firebaseController.dart';
import 'package:urmy_dev_client_v2/Controller/firebaseController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'dart:io';

class RegisterRepository {
  final Reader read;
  FirebaseAuth auth = FirebaseAuth.instance;
  UrData urdata = UrData();

  RegisterRepository({this.read});

  Future<void> setPersonalInfo(String email, String password, String nickname, String name, String phoneNo, Gender gender) async{

    urdata.email = email;
    urdata.password = password;
    urdata.nickname = nickname;
    urdata.name = name;
    if(phoneNo.contains("-")) {
      urdata.phoneNo = phoneNo.replaceAll("-", "");
    } else {
      urdata.phoneNo = phoneNo;
    }

    if(gender == Gender.MAN){
      urdata.genderState = true;
    } else {
      urdata.genderState = false;
    }

    /*
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: urdata.email,
          password: urdata.password
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }

     */
  }


  Future<bool> register(String birthdate, File imageFile) async {
    final String baseUrl = read(appConfigProvider).state.baseUrl;

    //final String url = '$baseUrl/register';
    var url = Uri.parse('$baseUrl/register');
    urdata.birthdate = birthdate;
    print(urdata.password);


    await Future.delayed(Duration(seconds: 2));
    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          'loginId': urdata.email,
          'password': urdata.password,
          'nickname' : urdata.nickname,
          'name' : urdata.name,
          'phoneNo' : urdata.phoneNo,
          'gender' : urdata.genderState,
          'birthdate': urdata.birthdate,
        },
      ),
    );
    print(response);
    if (response.statusCode != 201) {
         print('${response.statusCode}: ${response.reasonPhrase}');
         throw Exception('Fail to register');
    } else {
      if (imageFile == null) {
        await FirebaseController.instanace.saveUserDataToFirebaseDatabase(urdata.email,urdata.nickname,urdata.name,urdata.phoneNo,urdata.genderState,urdata.birthdate,"Not Registered");
      } else {
        String downloadUrl = await FirebaseController.instanace.saveUserImageToFirebaseStorage(urdata.email,urdata.nickname,urdata.name,urdata.phoneNo,urdata.genderState,urdata.birthdate,imageFile);
        urdata.imageFile = downloadUrl;
      }
      return saveData(urdata);
    }
  }

  Future<bool> saveData(UrData urdata) async {
    var personaldatastorage = Hive.box<UrData>('urmy');
    personaldatastorage.put('urdata', urdata);

    if (personaldatastorage.get('urdata').email != null) {
      print("personal data saved success");
      print(personaldatastorage.get('urdata').email);
      return true;
    }else {
      return false;
    }
  }

}
