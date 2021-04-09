import 'package:meta/meta.dart';
import 'package:hive/hive.dart';

part 'key_config.g.dart';

@HiveType(typeId: 3)
class KeyConfig extends HiveObject{
  @HiveField(0)
  String ServerKey;

  KeyConfig({
    @required this.ServerKey,
  });

}