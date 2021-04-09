import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/repositories/friendlist_repository.dart';

final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FriendRepository(read: ref.read);
});
