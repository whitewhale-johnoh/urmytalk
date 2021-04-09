import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/providers/friendlist_repository_provider.dart';
import 'package:urmy_dev_client_v2/models/models.dart';
import 'package:urmy_dev_client_v2/Controller/utils.dart';
import 'package:urmy_dev_client_v2/Controller/firebaseController.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:urmy_dev_client_v2/repositories/friendlist_repository.dart';

class FriendState {
  final int curruentindex;
  final bool loading;
  final String error;
  final List<FriendsData> friendsdata;
  final List<Message> newMessage;
  final bool isOnline;
  final bool unread;
  final UrData urdata;
  final DocumentReference userRef;
  final FriendsInfo currentFriendsData;
  final FriendsData currentFriendsDetail;
  final Chatroom currentChatroom;
  final String messageType;
  final bool isShowSticker;

  FriendState({
    this.curruentindex = 0,
    this.loading = true,
    this.error = '',
    this.friendsdata,
    this.newMessage,
    this.isOnline,
    this.unread,
    this.urdata,
    this.userRef,
    this.currentFriendsData,
    this.currentFriendsDetail,
    this.currentChatroom,
    this.messageType,
    this.isShowSticker,
  });

  FriendState copyWith({
    int curruentindex,
    bool loading,
    String error,
    List<FriendsData> friendsdata,
    List<Message> newMessage,
    bool isOnline,
    bool unread,
    UrData urdata,
    DocumentReference userRef,
    FriendsInfo currentFriendsData,
    FriendsData currentFriendsDetail,
    Chatroom currentChatroom,
    String messageType,
    bool isShowSticker,
  }) {
    return FriendState(
        curruentindex: curruentindex ?? this.curruentindex,
        loading: loading ?? this.loading,
        error: error ?? this.error,
        friendsdata: friendsdata ?? this.friendsdata,
        newMessage: newMessage ?? this.newMessage,
        isOnline: isOnline ?? this.isOnline,
        unread: unread ?? this.unread,
        urdata: urdata ?? this.urdata,
        userRef: userRef ?? this.userRef,
        currentFriendsData: currentFriendsData ?? this.currentFriendsData,
        currentFriendsDetail: currentFriendsDetail ?? this.currentFriendsDetail,
        currentChatroom: currentChatroom ?? this.currentChatroom,
        messageType: messageType ?? this.messageType,
        isShowSticker: isShowSticker ?? this.isShowSticker,
    );
  }
}

final friendProvider = StateNotifierProvider<Friend>((ref) {
  return Friend(read: ref.read);
});

class Friend extends StateNotifier<FriendState> {
  final Reader read;
  static FriendState initialFriendsState = FriendState();

  Friend({this.read}) : super(initialFriendsState);

  Future<void> getMyData() async {
    try {
      final UrData myData = await read(friendRepositoryProvider).getMyData();
      state = state.copyWith(
          urdata: myData,
          userRef: FirebaseFirestore.instance
              .collection('users')
              .doc(myData.email.trim()),
          isShowSticker: false,
          loading: false,
          error: '');
    } catch (e) {
      print(e);
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }

  void onFocusChange() {
    state = state.copyWith(
        isShowSticker: false
    );
  }

  void getSticker() {
    state = state.copyWith(
      isShowSticker: !state.isShowSticker
    );
  }

  void setChatroomSetting(String urID, String friendID){
    Chatroom chatRoom = new Chatroom();
    chatRoom.chatID = makeChatId(urID, friendID);
    chatRoom.chatWithID = friendID;
    state = state.copyWith(
      currentChatroom: chatRoom
    );
  }

  void setCurrentFriendsData(FriendsInfo friendsdata) {
    state = state.copyWith(
      currentFriendsData: friendsdata,
    );
  }

  Future<void> getUnreadMSGCount() async{
    try {
     await read(friendRepositoryProvider).getUnreadMSGCount();
    } catch (e) {
      print(e);
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }

  Future<void> setFriendsDetail(String friendsId) async{
    state = state.copyWith(
        loading: true,
    );
    try {
       final FriendsData currentFriendsDetail = await read(friendRepositoryProvider).getFriendDetail(friendsId);
         state = state.copyWith(
         loading: false,
         currentFriendsDetail: currentFriendsDetail
       );
    } catch (e) {
      print(e);
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }

  Future<void> refreshContacts() async {
    state = state.copyWith(
      loading: true,
      error: '',
    );
    try {
      final List<String> friendsIDList = [];
      final List<FriendsData> friendsdata =
          await read(friendRepositoryProvider).refreshContacts();
      for (var friend in friendsdata) {
        friendsIDList.add(friend.email);
      }
      state = state.copyWith(loading: false, friendsdata: friendsdata, error: '');
    } catch (e) {
      print(e);
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }

  Future<void> openChatting(String phones) async {
    state = state.copyWith(
      unread: true,
      newMessage: [],
      isOnline: true,
    );
    try {
      final List<Message> messageList =
          await read(friendRepositoryProvider).openChatting(phones);
      state =
          state.copyWith(loading: false, newMessage: messageList, error: '');
    } catch (e) {
      print("hello");
      print(e);
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }

  void setContentType(String messageType){
    state = state.copyWith(
      messageType: messageType
    );
  }

  void setCurrentIndex(int index){
    state = state.copyWith(
      curruentindex: index
    );
  }

  Future<void> sendMessage(String content) async {
      await read(friendRepositoryProvider).sendChatting(state.currentChatroom.chatID, state.urdata.email, state.currentFriendsData.friendId, content, state.messageType, state.urdata.name, state.currentFriendsData.FCMToken);
  }

/*
  Future<List<Message>> sendChatting(String friendID, Message message) async {
    state = state.copyWith(
      unread: true,
      isOnline: true,
    );
    try {
      final List<Message> newMessage =
          await read(friendRepositoryProvider).sendChatting(friendID, message);
      state = state.copyWith(loading: false, newMessage: newMessage, error: '');
      return newMessage;
    } catch (e) {
      print("hello2");
      print(e);
      state = state.copyWith(
        error: e.toString(),
      );
    }
  }

 */
}

final friendStateProvider = Provider<FriendState>((ref) {
  final FriendState friend = ref.watch(friendProvider.state);
  return friend;
});
