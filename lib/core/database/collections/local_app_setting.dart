import 'package:isar/isar.dart';

part 'local_app_setting.g.dart';

@collection
class LocalAppSetting {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String key;

  late String valueJson;
  late DateTime updatedAt;
}
