import 'package:gsma/core/database/embeddeds/sync_metadata_embedded.dart';
import 'package:isar/isar.dart';

part 'purchase_item_isar.g.dart';

@collection
class PurchaseItemIsar {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id;

  late String storeId;
  late String purchaseId;
  late String productId;

  double quantity = 0;
  late String unit;
  double rate = 0;
  double tax = 0;
  double amount = 0;
  String? batchId;

  late DateTime createdAt;

  SyncMetadataEmbedded sync = SyncMetadataEmbedded();
}
