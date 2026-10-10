import 'package:gsma/core/database/embeddeds/sync_metadata_embedded.dart';
import 'package:isar/isar.dart';

part 'product_isar.g.dart';

@collection
class ProductIsar {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id;

  late String storeId;
  late String name;

  @Index(caseSensitive: false)
  String? barcode;

  @Index(caseSensitive: false)
  String? sku;

  late String categoryId;
  String? brand;
  String? description;

  late String unitType;
  late String baseUnit;
  double conversionFactor = 1;

  double purchasePrice = 0;
  double sellingPrice = 0;
  double mrp = 0;
  double taxRate = 0;
  double discount = 0;

  double minimumStock = 0;
  double maximumStock = 0;

  String? supplierId;
  bool hasExpiry = false;
  bool hasBatch = false;
  bool isActive = true;

  late DateTime createdAt;
  late DateTime updatedAt;
  String? createdBy;
  String? updatedBy;

  SyncMetadataEmbedded sync = SyncMetadataEmbedded();
}
