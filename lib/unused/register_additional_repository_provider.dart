import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'file:///D:/work/flutter_urmy_v2/urmy_dev_client_v2/lib/unused/register_additional_repository.dart';

final RegisterAdditionalRepositoryProvider = Provider<RegisterAdditionalRepository>((ref) {
  return RegisterAdditionalRepository(read: ref.read);
});
