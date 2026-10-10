import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:gsma/core/network/connectivity_service.dart';
import 'package:gsma/core/sync/device_id_service.dart';
import 'package:gsma/core/sync/firestore_sync_processor.dart';
import 'package:gsma/core/sync/sync_manager.dart';

/// Avoids platform plugins and native Isar in widget tests.
class StubConnectivityService extends ConnectivityService {
  StubConnectivityService() : super(Connectivity());

  @override
  Future<ConnectivityService> init() async {
    isOnline.value = true;
    return this;
  }
}

class StubSyncManager extends SyncManager {
  StubSyncManager(super.isar, super.connectivity, super.processor);

  @override
  Future<SyncManager> init() async {
    pendingCount.value = 0;
    return this;
  }
}

FirestoreSyncProcessor stubSyncProcessor(
  IsarService isar,
  DeviceIdService device,
) =>
    FirestoreSyncProcessor(isar, device);
