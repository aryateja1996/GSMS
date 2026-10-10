import 'package:gsma/core/database/embeddeds/sync_metadata_embedded.dart';
import 'package:isar/isar.dart';

part 'sale_item_isar.g.dart';

@collection
class SaleItemIsar {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id;

  late String storeId;
  late String saleId;
  late String productId;

  late String productName;
  double quantity = 0;
  late String unit;
  double rate = 0;
  double discount = 0;
  double tax = 0;
  double amount = 0;

  /// Cost basis at time of sale for profit reporting.
  double costPrice = 0;

  String? batchId;

  late DateTime createdAt;

  SyncMetadataEmbedded sync = SyncMetadataEmbedded();
}
