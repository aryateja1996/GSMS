import 'package:gsma/core/database/embeddeds/sync_metadata_embedded.dart';
import 'package:isar/isar.dart';

part 'category_isar.g.dart';

@collection
class CategoryIsar {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id;

  late String storeId;
  late String name;
  String? description;
  bool isActive = true;
  late DateTime createdAt;
  late DateTime updatedAt;
  String? createdBy;
  String? updatedBy;

  SyncMetadataEmbedded sync = SyncMetadataEmbedded();
}
