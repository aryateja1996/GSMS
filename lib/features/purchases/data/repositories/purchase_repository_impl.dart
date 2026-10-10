import 'dart:convert';

import 'package:gsma/core/constants/stock_movement_type.dart';
import 'package:gsma/core/database/collections/purchase_isar.dart';
import 'package:gsma/core/database/collections/purchase_item_isar.dart';
import 'package:gsma/core/database/collections/stock_movement_isar.dart';
import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/core/sync/sync_enqueue_service.dart';
import 'package:gsma/core/sync/sync_status.dart';
import 'package:gsma/core/utils/id_generator.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/inventory/data/mappers/stock_movement_mapper.dart';
import 'package:gsma/features/inventory/domain/entities/stock_movement.dart';
import 'package:gsma/features/products/data/datasources/local/product_local_datasource.dart';
import 'package:gsma/features/purchases/data/datasources/local/purchase_local_datasource.dart';
import 'package:gsma/features/purchases/domain/entities/purchase.dart';
import 'package:gsma/features/purchases/domain/repositories/purchase_repository.dart';
import 'package:gsma/features/suppliers/data/datasources/local/supplier_local_datasource.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  PurchaseRepositoryImpl(
    this._purchaseLocal,
    this._productLocal,
    this._supplierLocal,
    this._store,
    this._syncEnqueue,
  );

  final PurchaseLocalDataSource _purchaseLocal;
  final ProductLocalDataSource _productLocal;
  final SupplierLocalDataSource _supplierLocal;
  final StoreContext _store;
  final SyncEnqueueService _syncEnqueue;

  Future<Purchase> _mapPurchase(PurchaseIsar p) async {
    final supplier = await _supplierLocal.getById(p.supplierId);
    final items = await _purchaseLocal.itemsForPurchase(p.id);
    final lines = <PurchaseLine>[];
    for (final item in items) {
      final product = await _productLocal.getById(item.productId);
      lines.add(
        PurchaseLine(
          productId: item.productId,
          productName: product?.name ?? item.productId,
          quantity: item.quantity,
          unit: item.unit,
          rate: item.rate,
          amount: item.amount,
        ),
      );
    }
    return Purchase(
      id: p.id,
      storeId: p.storeId,
      supplierId: p.supplierId,
      supplierName: supplier?.name ?? p.supplierId,
      invoiceNumber: p.invoiceNumber,
      purchaseDate: p.purchaseDate,
      subtotal: p.subtotal,
      discount: p.discount,
      tax: p.tax,
      total: p.total,
      paidAmount: p.paidAmount,
      dueAmount: p.dueAmount,
      paymentStatus: p.paymentStatus,
      lines: lines,
      createdAt: p.createdAt,
    );
  }

  @override
  Future<List<Purchase>> listPurchases({int limit = 50}) async {
    final list = await _purchaseLocal.listRecent(_store.storeId, limit: limit);
    final out = <Purchase>[];
    for (final p in list) {
      out.add(await _mapPurchase(p));
    }
    return out;
  }

  @override
  Future<Result<Purchase>> createPurchase(CreatePurchaseInput input) async {
    if (!_store.hasStore) {
      return const ErrorResult(CacheFailure('No store selected'));
    }
    if (input.lines.isEmpty) {
      return const ErrorResult(ValidationFailure('Add at least one product'));
    }

    final supplier = await _supplierLocal.getById(input.supplierId);
    if (supplier == null) {
      return const ErrorResult(ValidationFailure('Supplier not found'));
    }

    var subtotal = 0.0;
    final purchaseId = IdGenerator.newId();
    final now = DateTime.now();
    final itemModels = <PurchaseItemIsar>[];
    final stockMovements = <StockMovementIsar>[];

    for (final line in input.lines) {
      final product = await _productLocal.getById(line.productId);
      if (product == null) {
        return ErrorResult(ValidationFailure('Product ${line.productId} not found'));
      }
      final amount = line.quantity * line.rate;
      subtotal += amount;

      itemModels.add(
        PurchaseItemIsar()
          ..id = IdGenerator.newId()
          ..storeId = _store.storeId
          ..purchaseId = purchaseId
          ..productId = line.productId
          ..quantity = line.quantity
          ..unit = product.baseUnit
          ..rate = line.rate
          ..tax = 0
          ..amount = amount
          ..createdAt = now
          ..sync.syncStatus = SyncStatus.pending.name,
      );

      final movement = StockMovement(
        id: IdGenerator.newId(),
        storeId: _store.storeId,
        productId: line.productId,
        type: StockMovementType.purchase,
        quantity: line.quantity,
        unit: product.baseUnit,
        referenceId: purchaseId,
        reason: 'Purchase ${input.invoiceNumber}',
        createdBy: _store.userId,
        createdAt: now,
      );
      stockMovements.add(StockMovementMapper.toIsar(movement));
    }

    final total = subtotal - input.discount + input.tax;
    final paid = input.paidAmount.clamp(0.0, total).toDouble();
    final due = total - paid;
    final status = due <= 0 ? 'paid' : paid > 0 ? 'partial' : 'due';

    final purchase = PurchaseIsar()
      ..id = purchaseId
      ..storeId = _store.storeId
      ..supplierId = input.supplierId
      ..invoiceNumber = input.invoiceNumber.trim()
      ..purchaseDate = now
      ..subtotal = subtotal
      ..discount = input.discount
      ..tax = input.tax
      ..total = total
      ..paidAmount = paid
      ..dueAmount = due
      ..paymentStatus = status
      ..createdBy = _store.userId
      ..createdAt = now
      ..updatedAt = now
      ..sync.syncStatus = SyncStatus.pending.name;

    await _purchaseLocal.savePurchaseTransaction(
      purchase: purchase,
      items: itemModels,
      stockMovements: stockMovements,
    );

    await _syncEnqueue.enqueue(
      storeId: _store.storeId,
      entityType: 'purchases',
      entityId: purchaseId,
      action: 'create',
      payloadJson: jsonEncode({'id': purchaseId}),
    );

    return Success(await _mapPurchase(purchase));
  }

  @override
  Future<Result<Purchase>> recordSupplierPayment({
    required String purchaseId,
    required double amount,
  }) async {
    if (amount <= 0) {
      return const ErrorResult(ValidationFailure('Invalid payment amount'));
    }
    final purchase = await _purchaseLocal.getById(purchaseId);
    if (purchase == null) {
      return const ErrorResult(CacheFailure('Purchase not found'));
    }
    if (amount > purchase.dueAmount) {
      return const ErrorResult(ValidationFailure('Amount exceeds due balance'));
    }
    purchase.paidAmount += amount;
    purchase.dueAmount -= amount;
    purchase.paymentStatus =
        purchase.dueAmount <= 0 ? 'paid' : 'partial';
    purchase.updatedAt = DateTime.now();
    await _purchaseLocal.updatePurchase(purchase);
    return Success(await _mapPurchase(purchase));
  }

  @override
  Future<double> getSupplierOutstanding(String supplierId) async {
    final due = await _purchaseLocal.supplierOutstanding(
      _store.storeId,
      supplierId,
    );
    final supplier = await _supplierLocal.getById(supplierId);
    return due + (supplier?.openingBalance ?? 0);
  }
}
