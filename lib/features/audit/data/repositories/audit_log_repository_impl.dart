import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/features/audit/data/datasources/local/audit_log_local_datasource.dart';
import 'package:gsma/features/audit/domain/entities/audit_log_entry.dart';
import 'package:gsma/features/audit/domain/repositories/audit_log_repository.dart';

class AuditLogRepositoryImpl implements AuditLogRepository {
  AuditLogRepositoryImpl(this._local, this._store);

  final AuditLogLocalDataSource _local;
  final StoreContext _store;

  @override
  Future<List<AuditLogEntry>> listRecent({int limit = 100}) async {
    final rows = await _local.listRecent(_store.storeId, limit: limit);
    return rows
        .map(
          (r) => AuditLogEntry(
            id: r.id,
            userDisplayName: r.userDisplayName,
            action: r.action,
            entityType: r.entityType,
            entityId: r.entityId,
            oldValueJson: r.oldValueJson,
            newValueJson: r.newValueJson,
            createdAt: r.createdAt,
          ),
        )
        .toList();
  }
}
