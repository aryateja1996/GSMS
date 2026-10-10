import 'package:gsma/core/database/embeddeds/sync_metadata_embedded.dart';
import 'package:isar/isar.dart';

part 'audit_log_isar.g.dart';

@collection
class AuditLogIsar {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id;

  late String storeId;
  late String userId;
  late String userDisplayName;

  late String action;
  late String entityType;
  late String entityId;

  String? oldValueJson;
  String? newValueJson;
  late String deviceId;

  @Index()
  late DateTime createdAt;

  SyncMetadataEmbedded sync = SyncMetadataEmbedded();
}
