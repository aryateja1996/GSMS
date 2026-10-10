import 'package:get/get.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:gsma/core/network/connectivity_service.dart';
import 'package:gsma/core/sync/firestore_sync_processor.dart';
import 'package:gsma/core/utils/app_logger.dart';
import 'package:gsma/core/database/collections/sync_queue_item.dart';
import 'package:gsma/core/sync/sync_status.dart';
import 'package:isar/isar.dart';

/// Coordinates offline queue upload to Firestore when online.
class SyncManager extends GetxService {
  SyncManager(this._isarService, this._connectivity, this._processor);

  final IsarService _isarService;
  final ConnectivityService _connectivity;
  final FirestoreSyncProcessor _processor;

  final RxBool isSyncing = false.obs;
  final RxInt pendingCount = 0.obs;
  final RxInt failedCount = 0.obs;

  Worker? _connectivityWorker;

  Future<SyncManager> init() async {
    await refreshPendingCount();
    _connectivityWorker = ever<bool>(_connectivity.isOnline, (online) {
      if (online) {
        triggerSync();
      }
    });
    return this;
  }

  Future<void> refreshPendingCount() async {
    if (!_isarService.isReady) return;
    pendingCount.value = await _isarService.isar.syncQueueItems
        .where()
        .syncStatusEqualTo(SyncStatus.pending.name)
        .count();
    failedCount.value = await _isarService.isar.syncQueueItems
        .where()
        .syncStatusEqualTo(SyncStatus.failed.name)
        .count();
  }

  Future<void> triggerSync() async {
    if (!_connectivity.isOnline.value || isSyncing.value) return;
    if (!_isarService.isReady) return;
    if (!_processor.canSync) {
      AppLogger.info('Firebase unavailable — sync skipped', tag: 'Sync');
      await refreshPendingCount();
      return;
    }

    isSyncing.value = true;
    AppLogger.info('Sync started', tag: 'Sync');
    try {
      await _processor.processPendingQueue();
      await refreshPendingCount();
    } finally {
      isSyncing.value = false;
    }
  }

  @override
  void onClose() {
    _connectivityWorker?.dispose();
    super.onClose();
  }
}
