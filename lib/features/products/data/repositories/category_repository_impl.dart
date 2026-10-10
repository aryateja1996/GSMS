import 'dart:convert';

import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/core/sync/sync_enqueue_service.dart';
import 'package:gsma/core/utils/id_generator.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/products/data/datasources/local/category_local_datasource.dart';
import 'package:gsma/features/products/data/mappers/category_mapper.dart';
import 'package:gsma/features/products/domain/entities/category.dart';
import 'package:gsma/features/products/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._local, this._store, this._syncEnqueue);

  final CategoryLocalDataSource _local;
  final StoreContext _store;
  final SyncEnqueueService _syncEnqueue;

  @override
  Future<List<Category>> listCategories() async {
    final models = await _local.listActive(_store.storeId);
    return models.map(CategoryMapper.toEntity).toList();
  }

  @override
  Future<Result<Category>> saveCategory(Category category) async {
    if (!_store.hasStore) {
      return const ErrorResult(CacheFailure('No store selected'));
    }
    final now = DateTime.now();
    final entity = category.id.isEmpty
        ? Category(
            id: IdGenerator.newId(),
            storeId: _store.storeId,
            name: category.name,
            description: category.description,
            isActive: true,
            createdAt: now,
            updatedAt: now,
          )
        : Category(
            id: category.id,
            storeId: category.storeId,
            name: category.name,
            description: category.description,
            isActive: category.isActive,
            createdAt: category.createdAt,
            updatedAt: now,
          );

    await _local.save(CategoryMapper.toIsar(entity));
    await _syncEnqueue.enqueue(
      storeId: _store.storeId,
      entityType: 'categories',
      entityId: entity.id,
      action: category.id.isEmpty ? 'create' : 'update',
      payloadJson: jsonEncode({'id': entity.id}),
    );
    return Success(entity);
  }

  @override
  Future<Result<Category>> ensureDefaultCategory() async {
    final count = await _local.countForStore(_store.storeId);
    if (count > 0) {
      final list = await listCategories();
      return Success(list.first);
    }
    return saveCategory(
      Category(
        id: '',
        storeId: _store.storeId,
        name: 'General',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }
}
