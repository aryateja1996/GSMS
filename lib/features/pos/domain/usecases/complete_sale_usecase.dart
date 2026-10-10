import 'dart:convert';

import 'package:gsma/core/calculations/pos_line_calculator.dart';
import 'package:gsma/core/constants/payment_methods.dart';
import 'package:gsma/core/constants/stock_movement_type.dart';
import 'package:gsma/core/database/collections/sale_isar.dart';
import 'package:gsma/core/database/collections/sale_item_isar.dart';
import 'package:gsma/core/database/collections/stock_movement_isar.dart';
import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/core/sync/sync_enqueue_service.dart';
import 'package:gsma/core/sync/sync_status.dart';
import 'package:gsma/core/utils/id_generator.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/inventory/data/mappers/stock_movement_mapper.dart';
import 'package:gsma/features/inventory/domain/entities/stock_movement.dart';
import 'package:gsma/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:gsma/features/pos/data/datasources/local/sale_local_datasource.dart';
import 'package:gsma/features/pos/data/invoice_number_service.dart';
import 'package:gsma/features/khata/domain/repositories/khata_repository.dart';
import 'package:gsma/features/pos/domain/entities/pos_cart_line.dart';

class CompleteSaleResult {
  CompleteSaleResult({
    required this.saleId,
    required this.invoiceNumber,
    required this.total,
  });

  final String saleId;
  final String invoiceNumber;
  final double total;
}

class CompleteSaleUseCase {
  CompleteSaleUseCase({
    required this.store,
    required this.inventory,
    required this.saleLocal,
    required this.invoiceNumbers,
    required this.syncEnqueue,
    required this.khata,
  });

  final StoreContext store;
  final InventoryRepository inventory;
  final SaleLocalDataSource saleLocal;
  final InvoiceNumberService invoiceNumbers;
  final SyncEnqueueService syncEnqueue;
  final KhataRepository khata;

  Future<Result<CompleteSaleResult>> call({
    required List<PosCartLine> lines,
    required PaymentMethod paymentMethod,
    double billDiscount = 0,
    String? customerId,
  }) async {
    if (lines.isEmpty) {
      return const ErrorResult(ValidationFailure('Cart is empty'));
    }
    if (!store.hasStore) {
      return const ErrorResult(CacheFailure('No store selected'));
    }

    for (final line in lines) {
      final stock = await inventory.getStockQuantity(line.product.id);
      if (stock < line.quantity) {
        return ErrorResult(
          ValidationFailure('Insufficient stock for ${line.product.name}'),
        );
      }
    }

    final totals = PosLineCalculator.billTotals(
      lines: lines
          .map(
            (l) => (
              qty: l.quantity,
              rate: l.rate,
              lineDiscount: l.lineDiscount,
              taxRate: l.taxRate,
            ),
          )
          .toList(),
      billDiscount: billDiscount,
    );

    final saleId = IdGenerator.newId();
    final invoiceNumber = await invoiceNumbers.nextInvoiceNumber(store.storeId);
    final now = DateTime.now();
    final isCredit = paymentMethod == PaymentMethod.credit;
    if (isCredit && (customerId == null || customerId.isEmpty)) {
      return const ErrorResult(
        ValidationFailure('Select a customer for credit / Khata sale'),
      );
    }

    final sale = SaleIsar()
      ..id = saleId
      ..storeId = store.storeId
      ..invoiceNumber = invoiceNumber
      ..saleDate = now
      ..customerId = customerId
      ..paymentStatus = isCredit ? 'due' : 'paid'
      ..paymentMethodSummary = paymentMethod.name
      ..subtotal = totals.subtotal
      ..discount = totals.discount
      ..tax = totals.tax
      ..total = totals.total
      ..paidAmount = isCredit ? 0 : totals.total
      ..dueAmount = isCredit ? totals.total : 0
      ..createdBy = store.userId
      ..createdAt = now
      ..updatedAt = now
      ..sync.syncStatus = SyncStatus.pending.name;

    final items = <SaleItemIsar>[];
    final stockMovements = <StockMovementIsar>[];

    for (final line in lines) {
      final itemId = IdGenerator.newId();
      final amount = PosLineCalculator.lineAmount(
        quantity: line.quantity,
        rate: line.rate,
        lineDiscount: line.lineDiscount,
        taxRatePercent: line.taxRate,
      );
      final tax = PosLineCalculator.lineTax(
        quantity: line.quantity,
        rate: line.rate,
        lineDiscount: line.lineDiscount,
        taxRatePercent: line.taxRate,
      );

      items.add(
        SaleItemIsar()
          ..id = itemId
          ..storeId = store.storeId
          ..saleId = saleId
          ..productId = line.product.id
          ..productName = line.product.name
          ..quantity = line.quantity
          ..unit = line.product.baseUnit
          ..rate = line.rate
          ..discount = line.lineDiscount
          ..tax = tax
          ..amount = amount
          ..costPrice = line.product.purchasePrice
          ..createdAt = now
          ..sync.syncStatus = SyncStatus.pending.name,
      );

      final movement = StockMovement(
        id: IdGenerator.newId(),
        storeId: store.storeId,
        productId: line.product.id,
        type: StockMovementType.sale,
        quantity: line.quantity,
        unit: line.product.baseUnit,
        referenceId: saleId,
        reason: 'POS sale $invoiceNumber',
        createdBy: store.userId,
        createdAt: now,
      );
      stockMovements.add(StockMovementMapper.toIsar(movement));
    }

    await saleLocal.saveSaleTransaction(
      sale: sale,
      items: items,
      stockMovements: stockMovements,
    );

    await syncEnqueue.enqueue(
      storeId: store.storeId,
      entityType: 'sales',
      entityId: saleId,
      action: 'create',
      payloadJson: jsonEncode({'id': saleId, 'invoiceNumber': invoiceNumber}),
    );

    if (isCredit && customerId != null) {
      final khataResult = await khata.recordCreditSale(
        customerId: customerId,
        amount: totals.total,
        referenceId: saleId,
        description: 'Invoice $invoiceNumber',
      );
      if (khataResult case ErrorResult(failure: final failure)) {
        return ErrorResult(failure);
      }
    }

    return Success(
      CompleteSaleResult(
        saleId: saleId,
        invoiceNumber: invoiceNumber,
        total: totals.total,
      ),
    );
  }
}
