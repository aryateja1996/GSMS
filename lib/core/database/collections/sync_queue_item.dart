import 'package:isar/isar.dart';

part 'sync_queue_item.g.dart';

@collection
class SyncQueueItem {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String operationId;

  late String storeId;
  late String entityType;
  late String entityId;
  late String action;
  late String payloadJson;

  @Index()
  late String syncStatus;

  int attemptCount = 0;
  String? lastError;
  late DateTime createdAt;
  late DateTime updatedAt;
}
