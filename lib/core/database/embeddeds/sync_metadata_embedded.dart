import 'package:isar/isar.dart';

part 'sync_metadata_embedded.g.dart';

@embedded
class SyncMetadataEmbedded {
  String syncStatus = 'pending';
  String deviceId = '';
  int version = 1;
  DateTime? lastSyncedAt;
}
