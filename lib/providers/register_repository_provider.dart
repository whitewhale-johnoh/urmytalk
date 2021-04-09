import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/repositories/register_repository.dart';

final RegisterRepositoryProvider = Provider<RegisterRepository>((ref) {
  return RegisterRepository(read: ref.read);
});
