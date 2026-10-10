import 'package:gsma/core/database/embeddeds/sync_metadata_embedded.dart';
import 'package:isar/isar.dart';

part 'purchase_isar.g.dart';

@collection
class PurchaseIsar {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id;

  late String storeId;
  late String supplierId;
  late String invoiceNumber;

  @Index()
  late DateTime purchaseDate;

  double subtotal = 0;
  double discount = 0;
  double tax = 0;
  double total = 0;
  double paidAmount = 0;
  double dueAmount = 0;
  late String paymentStatus;

  String? createdBy;
  late DateTime createdAt;
  late DateTime updatedAt;
  String? updatedBy;

  SyncMetadataEmbedded sync = SyncMetadataEmbedded();
}
