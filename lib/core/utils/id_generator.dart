import 'package:uuid/uuid.dart';

abstract final class IdGenerator {
  static const _uuid = Uuid();

  static String newId() => _uuid.v4();
}
