class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.userDisplayName,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.createdAt,
    this.oldValueJson,
    this.newValueJson,
  });

  final String id;
  final String userDisplayName;
  final String action;
  final String entityType;
  final String entityId;
  final String? oldValueJson;
  final String? newValueJson;
  final DateTime createdAt;
}
