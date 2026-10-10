import 'package:get/get.dart';
import 'package:gsma/core/database/collections/sync_queue_item.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:gsma/core/sync/sync_manager.dart';
import 'package:gsma/core/sync/sync_status.dart';
import 'package:isar/isar.dart';

class SyncQueueController extends GetxController {
  SyncQueueController(this._isar, this._sync);

  final IsarService _isar;
  final SyncManager _sync;

  final RxList<SyncQueueItem> items = <SyncQueueItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final list = await _isar.isar.syncQueueItems.where().sortByUpdatedAtDesc().limit(100).findAll();
      items.assignAll(list);
      await _sync.refreshPendingCount();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncNow() async {
    await _sync.triggerSync();
    await load();
  }

  Future<void> retryFailed() async {
    await _isar.isar.writeTxn(() async {
      final failed = await _isar.isar.syncQueueItems
          .where()
          .syncStatusEqualTo(SyncStatus.failed.name)
          .findAll();
      for (final item in failed) {
        item.syncStatus = SyncStatus.pending.name;
        item.attemptCount = 0;
        item.lastError = null;
        item.updatedAt = DateTime.now();
        await _isar.isar.syncQueueItems.put(item);
      }
    });
    await _sync.triggerSync();
    await load();
  }
}
