import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:hive/hive.dart';
import 'package:urmy_dev_client_v2/models/models.dart';

class FirebaseController {
  static FirebaseController get instanace => FirebaseController();

  // Save Image to Storage
  Future<String> saveUserImageToFirebaseStorage(userId,nickname,userName,phoneNo,gender,birthdate,userImageFile) async {
    try {
      String filePath = 'userImages/$userId/profile/'+DateTime.now().millisecondsSinceEpoch.toString();
      print(filePath);
      print(userImageFile.runtimeType);
      final Reference storageReference = FirebaseStorage.instance.ref().child(filePath);
      final UploadTask uploadTask = storageReference.putFile(userImageFile);

      TaskSnapshot storageTaskSnapshot = await uploadTask;
      String imageURL = await storageTaskSnapshot.ref.getDownloadURL(); // Image URL from firebase's image file
      String result = await saveUserDataToFirebaseDatabase(userId,nickname,userName,phoneNo,gender,birthdate,imageURL);
      return result;
    }catch(e) {
      print("This is Saving User Image Error");
      print(e.message);
      return null;
    }
  }

  Future<String> sendImageToUserInChatRoom(croppedFile,chatID) async {
    try {
      String imageTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = 'chatrooms/$chatID/$imageTimeStamp';
      final Reference storageReference = FirebaseStorage.instance.ref().child(filePath);
      final UploadTask uploadTask = storageReference.putFile(croppedFile);
      TaskSnapshot storageTaskSnapshot = await uploadTask;
      String result = await storageTaskSnapshot.ref.getDownloadURL();
      return result;
    }catch(e) {
      print(e.message);
    }
  }

  // About Firebase Database

  Future<String> saveUserDataToFirebaseDatabase(userId,nickname,userName,phoneNo,gender,birthdate,downloadUrl) async {
    try {

      var personaltokenstorage = Hive.box<UrTokenData>('tokendata');
      final QuerySnapshot result = await FirebaseFirestore.instance.collection('users').where('FCMToken', isEqualTo: personaltokenstorage.get('tokendata').firebasetoken).get();

      final List<DocumentSnapshot> documents = result.docs;
      if (documents.length == 0) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'userId':userId,
          'nickname':nickname,
          'name':userName,
          'phoneNo':phoneNo,
          'gender':gender,
          'birthdate':birthdate,
          'userImageUrl':downloadUrl,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'FCMToken':personaltokenstorage.get('tokendata').firebasetoken?? 'NOToken',
        });
      }else {
        String userID = documents[0]['userId'];

        await FirebaseFirestore.instance.collection('users').doc(userID).update({
          'nickname':nickname,
          'name':userName,
          'phoneNo':phoneNo,
          'gender':gender,
          'birthdate':birthdate,
          'userImageUrl':downloadUrl,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'FCMToken':personaltokenstorage.get('tokendata').firebasetoken?? 'NOToken',
        });
      }
      return downloadUrl;
    }catch(e) {
      print("This is Error2");
      print(e.message);
      return null;
    }
  }

  Future<void> saveFriendData(String userId, String friendId) async {
   //try{
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('users').doc(userId).collection('friendsList').where('friendId', isEqualTo: friendId).get();
    final List<DocumentSnapshot> documents = result.docs;

    if(documents.length == 0) {
      //final QuerySnapshot friendsinfo = await FirebaseFirestore.instance.collection('users').where('userId', isEqualTo: friendId).get();
      //final List<DocumentSnapshot> friendsinfodoc = result.docs;

      final DocumentSnapshot friendsinfo = await FirebaseFirestore.instance.collection('users').doc(friendId).get();
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('friendsList').doc(friendId).set({
            'friendId' : friendsinfo['userId'],
          });
    }
  }

  Future<void> updateUserToken(userID, token) async {
    await FirebaseFirestore.instance.collection('users').doc(userID).update({
      'FCMToken':token,
    });
  }

  Future<List<DocumentSnapshot>> takeUserInformationFromFBDB() async{
    var personaltokenstorage = Hive.box<UrTokenData>('tokendata');
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('users').where('FCMToken', isEqualTo: personaltokenstorage.get('tokendata').firebasetoken ?? 'None').get();
    return result.docs;
  }

  Future<List<DocumentSnapshot>> takeFriendsInformationFromFBDB(String friendsList) async{
    final QuerySnapshot returnvalue = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: friendsList)
          .get();
    return returnvalue.docs;
  }

  Future<int> getUnreadMSGCount([String peerUserID]) async{
    try {
      int unReadMSGCount = 0;
      String targetID = '';
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      var personaldatastorage = Hive.box<UrData>('urmy');
      //peerUserID == null ? targetID = (prefs.get('userId') ?? 'NoId') : targetID = peerUserID;
      peerUserID == null ? targetID = (personaldatastorage.get('urdata').email ?? 'NoId') : targetID = peerUserID;
//      if (targetID != 'NoId') {
      final QuerySnapshot chatListResult =
      await FirebaseFirestore.instance.collection('users').doc(targetID).collection('chatlist').get();
      final List<DocumentSnapshot> chatListDocuments = chatListResult.docs;
      for(var data in chatListDocuments) {
        final QuerySnapshot unReadMSGDocument = await FirebaseFirestore.instance.collection('chatroom').
        doc(data['chatID']).
        collection(data['chatID']).
        where('idTo', isEqualTo: targetID).
        where('isread', isEqualTo: false).
        get();

        final List<DocumentSnapshot> unReadMSGDocuments = unReadMSGDocument.docs;
        unReadMSGCount = unReadMSGCount + unReadMSGDocuments.length;
      }
      print('unread MSG count is $unReadMSGCount');
//      }
      if (peerUserID == null) {
        FlutterAppBadger.updateBadgeCount(unReadMSGCount);
        return null;
      }else {
        return unReadMSGCount;
      }

    }catch(e) {
      print(e.message);
    }
  }

  Future updateChatRequestField(String documentID,String lastMessage,chatID,myID,selectedUserID) async{
    await FirebaseFirestore.instance
        .collection('users')
        .doc(documentID)
        .collection('chatlist')
        .doc(chatID)
        .set({'chatID':chatID,
      'chatWith':documentID == myID ? selectedUserID : myID,
      'lastChat':lastMessage,
      'timestamp':DateTime.now().millisecondsSinceEpoch});
  }

  Future sendMessageToChatRoom(chatID,myID,selectedUserID,content,messageType) async {
    await FirebaseFirestore.instance
        //.collection('users')
        //.doc(myID)
        .collection('chatroom')
        .doc(chatID)
        .collection(chatID)
        .doc(DateTime.now().millisecondsSinceEpoch.toString()).set({
      'idFrom': myID,
      'idTo': selectedUserID,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'content': content,
      'type':messageType,
      'isread':false,
    });
  }
}