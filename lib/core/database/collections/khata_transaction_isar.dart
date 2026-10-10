import 'package:gsma/core/database/embeddeds/sync_metadata_embedded.dart';
import 'package:isar/isar.dart';

part 'khata_transaction_isar.g.dart';

@collection
class KhataTransactionIsar {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id;

  late String storeId;
  late String customerId;

  @Index()
  late String type;

  double amount = 0;
  String? referenceId;
  String? description;
  double balanceAfter = 0;

  String? createdBy;

  @Index()
  late DateTime createdAt;

  SyncMetadataEmbedded sync = SyncMetadataEmbedded();
}
