import 'package:gsma/core/database/embeddeds/sync_metadata_embedded.dart';
import 'package:isar/isar.dart';

part 'supplier_isar.g.dart';

@collection
class SupplierIsar {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id;

  late String storeId;
  late String name;
  String? businessName;

  @Index()
  String? phone;

  String? email;
  String? address;
  String? gstNumber;
  double openingBalance = 0;
  double creditLimit = 0;
  String? paymentTerms;

  late DateTime createdAt;
  late DateTime updatedAt;
  String? createdBy;
  String? updatedBy;

  SyncMetadataEmbedded sync = SyncMetadataEmbedded();
}
