import 'package:hive/hive.dart';

part 'urmy_friends_model.g.dart';


@HiveType(typeId: 55)
class FriendsData extends HiveObject {
  @HiveField(0)
  String email;

  @HiveField(1)
  String name;

  @HiveField(2)
  String grade;

  @HiveField(3)
  String description;


  FriendsData(
      {this.email,
      this.name,
      this.grade,
      this.description,
      });

  factory FriendsData.fromJson(Map<dynamic, dynamic> parsedJson) {
    return FriendsData(
      email: parsedJson['LoginId'],
      name: parsedJson['Name'],
      grade: parsedJson['Grade'],
      description: parsedJson['Description'],
    );
  }
}

class FriendsRawData {
  String identifier;
  String givenName;
  String familyName;
  String phoneslabel;
  String phonesvalue;

  FriendsRawData(
      {this.identifier, this.givenName, this.familyName, this.phoneslabel, this.phonesvalue});

  factory FriendsRawData.fromJson(Map<dynamic, dynamic> parsedJson) {
    return FriendsRawData(
      identifier: parsedJson['identifier'],
      givenName: parsedJson['givenName'],
      familyName: parsedJson['familyName'],
      phoneslabel: PhoneData.fromJson(parsedJson['phones']).label,
      phonesvalue: PhoneData.fromJson(parsedJson['phones']).value,
    );
  }

  Map<dynamic, dynamic> toJSON() {
    return <dynamic, dynamic>{
      'identifier': identifier,
      'givenName' : givenName,
      'familyName': familyName,
      'phoneslabel': phoneslabel,
      'phonesvalue' : phonesvalue
    };
  }
}

class PhoneData {
  String label;
  String value;

  PhoneData({this.label, this.value});

  factory PhoneData.fromJson(List<dynamic> parsedJson) {
    var phonedata = PhoneData().toMap(parsedJson);
    return PhoneData(
        label: phonedata['label'],
      value: phonedata['value']
    );
  }

  Map<dynamic, dynamic> toMap(List<dynamic> parsedJson) {
    return {
      'label' : parsedJson.toString().substring(parsedJson[0].toString().indexOf('label:')+8, parsedJson[0].toString().indexOf(',')+1),
      'value' : parsedJson.toString().substring(parsedJson[0].toString().indexOf('value:')+8, parsedJson[0].toString().length)
    };
  }
  /*
  Map<dynamic, dynamic> toJSON() {
    return {
      'label' : label,
      'value' : value
    };
  }
*/
}

class FriendsInfo {
  String FCMToken;
  String friendId;
  String imageURL;
  String Name;
  String birthdate;

  FriendsInfo(this.FCMToken, this.friendId, this.imageURL, this.Name, this.birthdate);

}
