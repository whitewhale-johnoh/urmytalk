import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/providers/auth_repository_provider.dart';


class AuthState {
  final bool loggingIn;
  final bool autoLogin;
  final bool authenticated;
  final bool registered;
  final String error;

  AuthState({
    this.loggingIn = false,
    this.autoLogin = false,
    this.authenticated = false,
    this.registered = false,
    this.error = '',
  });

  AuthState copyWith({
    bool loggingIn,
    bool autoLogin,
    bool authenticated,
    bool registered,
    String error,
  }) {
    return AuthState(
      loggingIn: loggingIn ?? this.loggingIn,
      autoLogin: autoLogin ?? this.autoLogin,
      authenticated: authenticated ?? this.authenticated,
      registered: registered ?? this.registered,
      error: error ?? this.error,
    );
  }
}

final authProvider = StateNotifierProvider<Auth>((ref) {
  return Auth(read: ref.read);
});

class Auth extends StateNotifier<AuthState> {
  final Reader read;
  static AuthState initialAuthState = AuthState();
  Auth({this.read}) : super(initialAuthState);

  Future<void> login(String email, String password) async {
    state = state.copyWith(
      loggingIn: true,
      error: '',
    );

    try {
      bool isauthenticated = await read(authRepositoryProvider).login(email, password);
      state = state.copyWith(
        loggingIn: false,
        authenticated: isauthenticated,
      );
    } catch (e) {
      print(e);
      state = state.copyWith(
        loggingIn: false,
        error: e.toString(),
      );
    }
  }
/*
  Future<Map> searchForLoginData() async {
    try {
      final Map logindata = await read(authRepositoryProvider).searchForLoginData();
      state = state.copyWith(
        registered: true,
      );
      return logindata;
    } catch (e) {
      print(e);
      state = state.copyWith(
        registered: false,
      );
    }
    return null;
  }
*/
  Future<void> checkAutoLogin(bool value) async {
    state = state.copyWith(autoLogin: value);
  }

  Future<bool> tryAutoLogin() async {
    final bool authenticated = await read(authRepositoryProvider).tryAutoLogin();
    state = state.copyWith(authenticated: authenticated);
    return authenticated;
  }

  Future<void> logout() async {
    await read(authRepositoryProvider).logout();
    state = state.copyWith(
      loggingIn: false,
      authenticated: false,
      error: '',
    );
  }
}

final authStateProvider = Provider<AuthState>((ref) {
  final AuthState auth = ref.watch(authProvider.state);
  return auth;
});

