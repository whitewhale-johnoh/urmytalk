import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'file:///D:/work/flutter_urmy_v2/urmy_dev_client_v2/lib/unused/register_additional_repository_provider.dart';

class RegisterAdditionalState {
  final bool registeredAdditionalIn;
  final String error;

  RegisterAdditionalState({
    this.registeredAdditionalIn = false,
    this.error = '',
  });

  RegisterAdditionalState copyWith({
    bool registeredAdditionalIn,
    String error,
  }) {
    return RegisterAdditionalState(
      registeredAdditionalIn: registeredAdditionalIn ?? this.registeredAdditionalIn,
      error: error ?? this.error,
    );
  }
}

final registerAdditionalProvider = StateNotifierProvider<RegisterAdditional>((ref) {
  return RegisterAdditional(read: ref.read);
});

class RegisterAdditional extends StateNotifier<RegisterAdditionalState> {
  final Reader read;
  static RegisterAdditionalState initialAuthState = RegisterAdditionalState();
  RegisterAdditional({this.read}) : super(initialAuthState);

  Future<void> registerAdditional(String birthdate) async {
    state = state.copyWith(
      registeredAdditionalIn: true,
      error: '',
    );

    try {
      await read(RegisterAdditionalRepositoryProvider).registerAdditional(birthdate);
      state = state.copyWith(
        registeredAdditionalIn: false,
      );
    } catch (e) {
      print(e);
      state = state.copyWith(
        registeredAdditionalIn: false,
        error: e.toString(),
      );
    }

  }
}

final registerAdditionalStateProvider = Provider<RegisterAdditionalState>((ref) {
  final RegisterAdditionalState registerAdditional = ref.watch(registerAdditionalProvider.state);

  return registerAdditional;
});

