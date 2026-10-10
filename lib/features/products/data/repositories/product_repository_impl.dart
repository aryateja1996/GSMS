import 'dart:convert';

import 'package:gsma/core/audit/audit_log_service.dart';
import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/core/sync/sync_enqueue_service.dart';
import 'package:gsma/core/utils/id_generator.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/products/data/datasources/local/product_local_datasource.dart';
import 'package:gsma/features/products/data/mappers/product_mapper.dart';
import 'package:gsma/features/products/domain/entities/product.dart';
import 'package:gsma/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(
    this._local,
    this._store,
    this._syncEnqueue,
  );

  final ProductLocalDataSource _local;
  final StoreContext _store;
  final SyncEnqueueService _syncEnqueue;

  @override
  Future<List<Product>> listProducts({
    String? categoryId,
    String? query,
    int limit = 100,
    int offset = 0,
  }) async {
    final models = await _local.listActive(
      _store.storeId,
      categoryId: categoryId,
      query: query,
      limit: limit,
      offset: offset,
    );
    return models.map(ProductMapper.toEntity).toList();
  }

  @override
  Future<Product?> getById(String id) async {
    final model = await _local.getById(id);
    return model == null ? null : ProductMapper.toEntity(model);
  }

  @override
  Future<Product?> getByBarcode(String barcode) async {
    final model = await _local.getByBarcode(_store.storeId, barcode.trim());
    return model == null ? null : ProductMapper.toEntity(model);
  }

  @override
  Future<Result<Product>> saveProduct(Product product) async {
    if (!_store.hasStore) {
      return const ErrorResult(CacheFailure('No store selected'));
    }
    final now = DateTime.now();
    final toSave = product.id.isEmpty
        ? product.copyWithId(
            id: IdGenerator.newId(),
            storeId: _store.storeId,
            createdAt: now,
            updatedAt: now,
          )
        : product.copyWithUpdated(now);

    final isar = ProductMapper.toIsar(toSave);
    await _local.save(isar);
    await _syncEnqueue.enqueue(
      storeId: _store.storeId,
      entityType: 'products',
      entityId: toSave.id,
      action: product.id.isEmpty ? 'create' : 'update',
      payloadJson: jsonEncode({'id': toSave.id}),
    );
    await AuditLogService.optional?.record(
      action: product.id.isEmpty ? 'product_created' : 'product_updated',
      entityType: 'product',
      entityId: toSave.id,
      newValue: {'name': toSave.name, 'sellingPrice': toSave.sellingPrice},
    );
    return Success(toSave);
  }

  @override
  Future<Result<void>> deactivateProduct(String id) async {
    final existing = await _local.getById(id);
    if (existing == null) {
      return const ErrorResult(CacheFailure('Product not found'));
    }
    existing.isActive = false;
    existing.updatedAt = DateTime.now();
    await _local.save(existing);
    await _syncEnqueue.enqueue(
      storeId: _store.storeId,
      entityType: 'products',
      entityId: id,
      action: 'deactivate',
      payloadJson: jsonEncode({'id': id}),
    );
    return const Success(null);
  }
}

extension on Product {
  Product copyWithId({
    required String id,
    required String storeId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return Product(
      id: id,
      storeId: storeId,
      name: name,
      barcode: barcode,
      sku: sku,
      categoryId: categoryId,
      brand: brand,
      description: description,
      unitType: unitType,
      baseUnit: baseUnit,
      conversionFactor: conversionFactor,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      mrp: mrp,
      taxRate: taxRate,
      discount: discount,
      minimumStock: minimumStock,
      maximumStock: maximumStock,
      supplierId: supplierId,
      hasExpiry: hasExpiry,
      hasBatch: hasBatch,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Product copyWithUpdated(DateTime updatedAt) {
    return Product(
      id: id,
      storeId: storeId,
      name: name,
      barcode: barcode,
      sku: sku,
      categoryId: categoryId,
      brand: brand,
      description: description,
      unitType: unitType,
      baseUnit: baseUnit,
      conversionFactor: conversionFactor,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      mrp: mrp,
      taxRate: taxRate,
      discount: discount,
      minimumStock: minimumStock,
      maximumStock: maximumStock,
      supplierId: supplierId,
      hasExpiry: hasExpiry,
      hasBatch: hasBatch,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
