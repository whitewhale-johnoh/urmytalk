import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(read: ref.read);
});
