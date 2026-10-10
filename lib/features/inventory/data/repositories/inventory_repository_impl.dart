import 'dart:convert';

import 'package:gsma/core/calculations/stock_calculator.dart';
import 'package:gsma/core/constants/stock_movement_type.dart';
import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/core/sync/sync_enqueue_service.dart';
import 'package:gsma/core/utils/id_generator.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/inventory/data/datasources/local/stock_local_datasource.dart';
import 'package:gsma/features/inventory/data/mappers/stock_movement_mapper.dart';
import 'package:gsma/features/inventory/domain/entities/stock_movement.dart';
import 'package:gsma/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:gsma/features/products/data/datasources/local/product_local_datasource.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl(
    this._stockLocal,
    this._productLocal,
    this._store,
    this._syncEnqueue,
  );

  final StockLocalDataSource _stockLocal;
  final ProductLocalDataSource _productLocal;
  final StoreContext _store;
  final SyncEnqueueService _syncEnqueue;

  @override
  Future<double> getStockQuantity(String productId) async {
    final movements = await _stockLocal.movementsForProduct(
      _store.storeId,
      productId,
    );
    return StockCalculator.balanceFromMovements(
      movements
          .map(
            (m) => StockMovementQuantity(
              type: StockMovementTypeX.fromString(m.type),
              quantity: m.quantity,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<Result<StockMovement>> recordMovement({
    required String productId,
    required StockMovementType type,
    required double quantity,
    required String unit,
    String? referenceId,
    String? reason,
  }) async {
    if (!_store.hasStore) {
      return const ErrorResult(CacheFailure('No store selected'));
    }
    if (quantity <= 0) {
      return const ErrorResult(ValidationFailure('Quantity must be greater than zero'));
    }

    if (!type.increasesStock) {
      final current = await getStockQuantity(productId);
      if (current - quantity < 0) {
        return const ErrorResult(
          ValidationFailure('Insufficient stock for this operation'),
        );
      }
    }

    final entity = StockMovement(
      id: IdGenerator.newId(),
      storeId: _store.storeId,
      productId: productId,
      type: type,
      quantity: quantity,
      unit: unit,
      referenceId: referenceId,
      reason: reason,
      createdBy: _store.userId,
      createdAt: DateTime.now(),
    );

    await _stockLocal.saveMovement(StockMovementMapper.toIsar(entity));
    await _syncEnqueue.enqueue(
      storeId: _store.storeId,
      entityType: 'stockMovements',
      entityId: entity.id,
      action: 'create',
      payloadJson: jsonEncode({'id': entity.id}),
    );
    return Success(entity);
  }

  @override
  Future<List<StockMovement>> recentMovements({int limit = 50}) async {
    final models = await _stockLocal.recentMovements(_store.storeId, limit: limit);
    return models.map(StockMovementMapper.toEntity).toList();
  }

  @override
  Future<List<ProductStockSummary>> listStockSummaries({String? query}) async {
    final products = await _productLocal.listActive(
      _store.storeId,
      query: query,
      limit: 500,
    );
    final summaries = <ProductStockSummary>[];
    for (final p in products) {
      final qty = await getStockQuantity(p.id);
      summaries.add(
        ProductStockSummary(
          productId: p.id,
          productName: p.name,
          unit: p.baseUnit,
          quantity: qty,
          minimumStock: p.minimumStock,
        ),
      );
    }
    summaries.sort((a, b) => a.productName.compareTo(b.productName));
    return summaries;
  }
}
