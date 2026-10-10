import 'package:gsma/core/database/collections/category_isar.dart';
import 'package:gsma/core/sync/sync_status.dart';
import 'package:gsma/features/products/domain/entities/category.dart';

abstract final class CategoryMapper {
  static Category toEntity(CategoryIsar model) {
    return Category(
      id: model.id,
      storeId: model.storeId,
      name: model.name,
      description: model.description,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static CategoryIsar toIsar(Category entity, {String? deviceId}) {
    return CategoryIsar()
      ..id = entity.id
      ..storeId = entity.storeId
      ..name = entity.name
      ..description = entity.description
      ..isActive = entity.isActive
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..sync.syncStatus = SyncStatus.pending.name
      ..sync.deviceId = deviceId ?? ''
      ..sync.version = 1;
  }
}
