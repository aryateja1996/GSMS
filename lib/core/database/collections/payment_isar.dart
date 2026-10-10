import 'package:gsma/core/database/embeddeds/sync_metadata_embedded.dart';
import 'package:isar/isar.dart';

part 'payment_isar.g.dart';

@collection
class PaymentIsar {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id;

  late String storeId;

  /// e.g. customer, supplier
  late String partyType;
  late String partyId;

  double amount = 0;
  late String paymentMethod;
  String? referenceId;
  String? description;

  @Index()
  late DateTime paymentDate;

  String? createdBy;
  late DateTime createdAt;

  SyncMetadataEmbedded sync = SyncMetadataEmbedded();
}
