enum SyncStatus {
  pending,
  syncing,
  synced,
  failed,
  conflict,
}

extension SyncStatusX on SyncStatus {
  String get label => name.toUpperCase();
}

SyncStatus syncStatusFromString(String value) {
  return SyncStatus.values.firstWhere(
    (e) => e.name == value.toLowerCase(),
    orElse: () => SyncStatus.pending,
  );
}
