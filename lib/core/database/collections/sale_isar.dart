import 'package:gsma/core/database/embeddeds/sync_metadata_embedded.dart';
import 'package:isar/isar.dart';

part 'sale_isar.g.dart';

@collection
class SaleIsar {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id;

  late String storeId;
  late String invoiceNumber;

  @Index()
  late DateTime saleDate;

  String? customerId;
  late String paymentStatus;
  late String paymentMethodSummary;

  double subtotal = 0;
  double discount = 0;
  double tax = 0;
  double total = 0;
  double paidAmount = 0;
  double dueAmount = 0;

  String? notes;
  String? createdBy;

  late DateTime createdAt;
  late DateTime updatedAt;
  String? updatedBy;

  SyncMetadataEmbedded sync = SyncMetadataEmbedded();
}
