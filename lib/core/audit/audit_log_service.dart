import 'dart:convert';

import 'package:get/get.dart';
import 'package:gsma/core/database/collections/audit_log_isar.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/core/sync/device_id_service.dart';
import 'package:gsma/core/sync/sync_enqueue_service.dart';
import 'package:gsma/core/sync/sync_status.dart';
import 'package:gsma/core/utils/id_generator.dart';
import 'package:gsma/features/auth/presentation/controllers/auth_controller.dart';

class AuditLogService extends GetxService {
  AuditLogService(
    this._isar,
    this._store,
    this._deviceId,
    this._syncEnqueue,
  );

  final IsarService _isar;
  final StoreContext _store;
  final DeviceIdService _deviceId;
  final SyncEnqueueService _syncEnqueue;

  static AuditLogService? get optional =>
      Get.isRegistered<AuditLogService>() ? Get.find<AuditLogService>() : null;

  Future<void> record({
    required String action,
    required String entityType,
    required String entityId,
    Object? oldValue,
    Object? newValue,
  }) async {
    if (!_store.hasStore) return;

    final auth = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    final user = auth?.user.value;
    final now = DateTime.now();
    final id = IdGenerator.newId();

    final row = AuditLogIsar()
      ..id = id
      ..storeId = _store.storeId
      ..userId = user?.id ?? _store.userId
      ..userDisplayName = user?.displayName.isNotEmpty == true
          ? user!.displayName
          : (user?.email ?? 'System')
      ..action = action
      ..entityType = entityType
      ..entityId = entityId
      ..oldValueJson = oldValue == null ? null : jsonEncode(oldValue)
      ..newValueJson = newValue == null ? null : jsonEncode(newValue)
      ..deviceId = _deviceId.deviceId
      ..createdAt = now
      ..sync.syncStatus = SyncStatus.pending.name;

    await _isar.isar.writeTxn(() async {
      await _isar.isar.auditLogIsars.put(row);
    });

    await _syncEnqueue.enqueue(
      storeId: _store.storeId,
      entityType: 'auditLogs',
      entityId: id,
      action: 'create',
      payloadJson: jsonEncode({'id': id}),
    );
  }
}
