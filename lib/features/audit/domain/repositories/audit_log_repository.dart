import 'package:gsma/features/audit/domain/entities/audit_log_entry.dart';

abstract class AuditLogRepository {
  Future<List<AuditLogEntry>> listRecent({int limit = 100});
}
