import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/Auth/register.dart';
import 'package:urmy_dev_client_v2/providers/register_repository_provider.dart';
import 'package:image_picker/image_picker.dart';

class RegisterState {
  final bool registeredIn;
  final String error;
  final File imageFile;

  RegisterState({
    this.registeredIn = false,
    this.error = '',
    this.imageFile = null,
  });

  RegisterState copyWith({
    bool registeredIn,
    String error,
    imageFile,
  }) {
    return RegisterState(
      registeredIn: registeredIn ?? this.registeredIn,
      error: error ?? this.error,
      imageFile: imageFile ?? this.imageFile,
    );
  }
}

final registerProvider = StateNotifierProvider<Register>((ref) {
  return Register(read: ref.read);
});

class Register extends StateNotifier<RegisterState> {
  final Reader read;
  static RegisterState initialAuthState = RegisterState();
  Register({this.read}) : super(initialAuthState);

  Future<void> setPersonalData(String email, String password, String nickname, String name, String phoneNo, Gender gender) async{
    try {
      await read(RegisterRepositoryProvider).setPersonalInfo(email, password, nickname, name, phoneNo, gender);
    } catch (e) {
      print(e);
    }
  }

  Future<void> register(String birthdate) async {
    try {
      bool isregistered = await read(RegisterRepositoryProvider).register(birthdate, state.imageFile);
      state = state.copyWith(
        registeredIn: isregistered,
      );
    } catch (e) {
      print(e);
      state = state.copyWith(
        registeredIn: false,
        error: e.toString(),
      );
    }
  }

  Future<void> takePhoto(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.getImage(source: source);
    print(pickedFile.runtimeType);
    try {
      state = state.copyWith(
        imageFile: File(pickedFile.path),
      );
    } catch (e) {
      print(e);
    }
  }

  /*
  String getSessionId() {
    return read(RegisterRepositoryProvider).getSessionId();
  }
  */

}

final registerStateProvider = Provider<RegisterState>((ref) {
  final RegisterState register = ref.watch(registerProvider.state);

  return register;
});

