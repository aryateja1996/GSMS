import 'package:gsma/core/database/embeddeds/sync_metadata_embedded.dart';
import 'package:isar/isar.dart';

part 'expense_isar.g.dart';

@collection
class ExpenseIsar {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id;

  late String storeId;
  late String category;
  double amount = 0;
  late String paymentMethod;
  String? description;

  @Index()
  late DateTime date;

  String? createdBy;
  late DateTime createdAt;
  late DateTime updatedAt;

  SyncMetadataEmbedded sync = SyncMetadataEmbedded();
}
