import 'package:gsma/core/database/collections/audit_log_isar.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:isar/isar.dart';

class AuditLogLocalDataSource {
  AuditLogLocalDataSource(this._isar);

  final IsarService _isar;

  Future<List<AuditLogIsar>> listRecent(String storeId, {int limit = 100}) {
    return _isar.isar.auditLogIsars
        .filter()
        .storeIdEqualTo(storeId)
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }
}
