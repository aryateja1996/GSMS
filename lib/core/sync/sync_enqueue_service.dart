import 'package:get/get.dart';
import 'package:gsma/core/database/collections/sync_queue_item.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:gsma/core/sync/device_id_service.dart';
import 'package:gsma/core/sync/sync_manager.dart';
import 'package:gsma/core/sync/sync_status.dart';
import 'package:gsma/core/utils/id_generator.dart';

class SyncEnqueueService extends GetxService {
  SyncEnqueueService(this._isar, DeviceIdService _, this._syncManager);

  final IsarService _isar;
  final SyncManager _syncManager;

  Future<void> enqueue({
    required String storeId,
    required String entityType,
    required String entityId,
    required String action,
    required String payloadJson,
  }) async {
    final now = DateTime.now();
    final item = SyncQueueItem()
      ..operationId = IdGenerator.newId()
      ..storeId = storeId
      ..entityType = entityType
      ..entityId = entityId
      ..action = action
      ..payloadJson = payloadJson
      ..syncStatus = SyncStatus.pending.name
      ..createdAt = now
      ..updatedAt = now;

    await _isar.isar.writeTxn(() async {
      await _isar.isar.syncQueueItems.put(item);
    });
    await _syncManager.refreshPendingCount();
  }
}
