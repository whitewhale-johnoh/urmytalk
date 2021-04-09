import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
part 'urmy_model.g.dart';

@HiveType(typeId: 5)
class UrData extends HiveObject {
  @HiveField(0)
  String email;
  @HiveField(1)
  String password;
  @HiveField(3)
  String nickname;
  @HiveField(4)
  String name;
  @HiveField(5)
  String phoneNo;
  @HiveField(6)
  bool genderState;
  @HiveField(7)
  String birthdate;
  @HiveField(8)
  String intro;
  @HiveField(9)
  String imageFile;

  UrData({
    @required this.email,
    @required this.password,
    @required this.nickname,
    @required this.name,
    @required this.phoneNo,
    @required this.genderState,
    @required this.birthdate,
    this.intro,
    this.imageFile,
  });

  factory UrData.fromJson(Map<String, dynamic> parsedJson) {
    return UrData(
      email: parsedJson['loginId'],
      password: parsedJson['password'],
      nickname: parsedJson['nickname'],
      name: parsedJson['name'],
      phoneNo: parsedJson['phoneNo'],
      genderState: parsedJson['gender'],
      birthdate: parsedJson['birthdate'],
      intro: parsedJson['intro'],
    );
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'loginId': email,
      'password': password,
      'nickname': nickname,
      'name': name,
      'phoneNo': phoneNo,
      'gender': genderState,
      'birthdate': birthdate,
      'intro' : intro,
    };
  }
}

@HiveType(typeId: 25)
class UrTokenData extends HiveObject {
  @HiveField(0)
  String accesstoken;
  @HiveField(1)
  String refreshtoken;
  @HiveField(2)
  String firebasetoken;

  UrTokenData({
    this.accesstoken,
    this.refreshtoken,
    this.firebasetoken,
  });
}
