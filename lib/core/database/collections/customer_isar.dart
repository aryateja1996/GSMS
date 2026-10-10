import 'package:gsma/core/database/embeddeds/sync_metadata_embedded.dart';
import 'package:isar/isar.dart';

part 'customer_isar.g.dart';

@collection
class CustomerIsar {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id;

  late String storeId;
  late String name;

  @Index()
  String? phone;

  String? email;
  String? address;
  double openingBalance = 0;
  double creditLimit = 0;
  bool isActive = true;

  late DateTime createdAt;
  late DateTime updatedAt;
  String? createdBy;
  String? updatedBy;

  SyncMetadataEmbedded sync = SyncMetadataEmbedded();
}
