import 'package:gsma/core/database/embeddeds/sync_metadata_embedded.dart';
import 'package:isar/isar.dart';

part 'stock_movement_isar.g.dart';

@collection
class StockMovementIsar {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id;

  late String storeId;
  late String productId;

  @Index()
  late String type;

  double quantity = 0;
  late String unit;
  String? referenceId;
  String? batchId;
  String? reason;

  String? createdBy;

  @Index()
  late DateTime createdAt;

  SyncMetadataEmbedded sync = SyncMetadataEmbedded();
}
