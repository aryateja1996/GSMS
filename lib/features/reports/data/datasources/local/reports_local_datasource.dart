import 'package:gsma/core/calculations/khata_calculator.dart';
import 'package:gsma/core/calculations/profit_calculator.dart';
import 'package:gsma/core/calculations/stock_calculator.dart';
import 'package:gsma/core/constants/khata_transaction_type.dart';
import 'package:gsma/core/constants/stock_movement_type.dart';
import 'package:gsma/core/constants/payment_methods.dart';
import 'package:gsma/core/database/collections/category_isar.dart';
import 'package:gsma/core/database/collections/customer_isar.dart';
import 'package:gsma/core/database/collections/product_isar.dart';
import 'package:gsma/core/database/collections/purchase_isar.dart';
import 'package:gsma/core/database/collections/sale_isar.dart';
import 'package:gsma/core/database/collections/sale_item_isar.dart';
import 'package:gsma/core/database/collections/stock_movement_isar.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:gsma/features/expenses/data/datasources/local/expense_local_datasource.dart';
import 'package:gsma/features/khata/data/datasources/local/khata_local_datasource.dart';
import 'package:isar/isar.dart';

class SalesPeriodTotals {
  const SalesPeriodTotals({
    required this.saleCount,
    required this.grossSales,
    required this.discounts,
    required this.tax,
    required this.netTotal,
    required this.costOfGoodsSold,
    required this.byPaymentMethod,
    required this.byProduct,
    required this.byCategory,
  });

  final int saleCount;
  final double grossSales;
  final double discounts;
  final double tax;
  final double netTotal;
  final double costOfGoodsSold;
  final Map<String, double> byPaymentMethod;
  final Map<String, double> byProduct;
  final Map<String, double> byCategory;
}

class InventoryReportSnapshot {
  const InventoryReportSnapshot({
    required this.stockValue,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.topProductsByQty,
  });

  final double stockValue;
  final int lowStockCount;
  final int outOfStockCount;
  final List<(String name, double qty)> topProductsByQty;
}

class ReportsLocalDataSource {
  ReportsLocalDataSource(
    this._isar,
    this._expenses,
    this._khata,
  );

  final IsarService _isar;
  final ExpenseLocalDataSource _expenses;
  final KhataLocalDataSource _khata;

  Future<SalesPeriodTotals> salesTotals(
    String storeId,
    DateTime from,
    DateTime to,
  ) async {
    final sales = await _isar.isar.saleIsars
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .saleDateBetween(from, to, includeLower: true, includeUpper: true)
        .findAll();

    var gross = 0.0;
    var discounts = 0.0;
    var tax = 0.0;
    var net = 0.0;
    var cogs = 0.0;
    final byPayment = <String, double>{};
    final byProduct = <String, double>{};
    final byCategory = <String, double>{};

    final productCategories = <String, String>{};
    final products = await _isar.isar.productIsars
        .filter()
        .storeIdEqualTo(storeId)
        .findAll();
    for (final p in products) {
      productCategories[p.id] = p.categoryId;
    }
    final categories = await _isar.isar.categoryIsars
        .filter()
        .storeIdEqualTo(storeId)
        .findAll();
    final categoryNames = {for (final c in categories) c.id: c.name};

    for (final sale in sales) {
      gross += sale.subtotal;
      discounts += sale.discount;
      tax += sale.tax;
      net += sale.total;
      byPayment[sale.paymentMethodSummary] =
          (byPayment[sale.paymentMethodSummary] ?? 0) + sale.total;

      final items = await _isar.isar.saleItemIsars
          .filter()
          .saleIdEqualTo(sale.id)
          .findAll();
      for (final item in items) {
        cogs += item.costPrice * item.quantity;
        byProduct[item.productName] =
            (byProduct[item.productName] ?? 0) + item.amount;
        final catId = productCategories[item.productId] ?? '';
        final catName = categoryNames[catId] ?? 'Uncategorized';
        byCategory[catName] = (byCategory[catName] ?? 0) + item.amount;
      }
    }

    return SalesPeriodTotals(
      saleCount: sales.length,
      grossSales: gross,
      discounts: discounts,
      tax: tax,
      netTotal: net,
      costOfGoodsSold: cogs,
      byPaymentMethod: byPayment,
      byProduct: byProduct,
      byCategory: byCategory,
    );
  }

  Future<double> purchaseTotalBetween(
    String storeId,
    DateTime from,
    DateTime to,
  ) async {
    final rows = await _isar.isar.purchaseIsars
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .purchaseDateBetween(from, to, includeLower: true, includeUpper: true)
        .findAll();
    var total = 0.0;
    for (final p in rows) {
      total += p.total;
    }
    return total;
  }

  Future<double> khataOutstanding(String storeId) async {
    final customers = await _isar.isar.customerIsars
        .filter()
        .storeIdEqualTo(storeId)
        .findAll();
    var total = 0.0;
    for (final c in customers) {
      final txs = await _khata.forCustomer(storeId, c.id);
      total += KhataCalculator.outstandingFromLedger(
        txs
            .map(
              (t) => KhataLedgerEntry(
                type: KhataTransactionTypeX.fromString(t.type),
                amount: t.amount,
              ),
            )
            .toList(),
      );
    }
    return total;
  }

  Future<double> khataCollectionsBetween(
    String storeId,
    DateTime from,
    DateTime to,
  ) async {
    final txs = await _khata.listBetween(storeId, from, to);
    var total = 0.0;
    for (final t in txs) {
      if (t.type == KhataTransactionType.payment.name) total += t.amount;
    }
    return total;
  }

  Future<double> creditSalesBetween(
    String storeId,
    DateTime from,
    DateTime to,
  ) async {
    final sales = await _isar.isar.saleIsars
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .saleDateBetween(from, to, includeLower: true, includeUpper: true)
        .findAll();
    var total = 0.0;
    for (final sale in sales) {
      if (sale.paymentMethodSummary == PaymentMethod.credit.name) {
        total += sale.total;
      }
    }
    return total;
  }

  Future<ProfitSummary> profitSummary(
    String storeId,
    DateTime from,
    DateTime to,
  ) async {
    final sales = await salesTotals(storeId, from, to);
    final expenseTotal =
        await _expenses.sumExpensesBetween(storeId, from, to);
    return ProfitCalculator.summarize(
      grossSales: sales.grossSales,
      discounts: sales.discounts,
      costOfGoodsSold: sales.costOfGoodsSold,
      expenses: expenseTotal,
    );
  }

  Future<InventoryReportSnapshot> inventorySnapshot(String storeId) async {
    final products = await _isar.isar.productIsars
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .isActiveEqualTo(true)
        .findAll();

    var stockValue = 0.0;
    var low = 0;
    var out = 0;
    final qtyByProduct = <String, (String name, double qty)>{};

    for (final p in products) {
      final movements = await _isar.isar.stockMovementIsars
          .filter()
          .storeIdEqualTo(storeId)
          .and()
          .productIdEqualTo(p.id)
          .findAll();
      final balance = StockCalculator.balanceFromMovements(
        movements
            .map(
              (m) => StockMovementQuantity(
                type: StockMovementTypeX.fromString(m.type),
                quantity: m.quantity,
              ),
            )
            .toList(),
      );
      stockValue += balance * p.purchasePrice;
      if (balance <= 0) {
        out++;
      } else if (p.minimumStock > 0 && balance <= p.minimumStock) {
        low++;
      }
      qtyByProduct[p.id] = (p.name, balance);
    }

    final top = qtyByProduct.values.toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));

    return InventoryReportSnapshot(
      stockValue: stockValue,
      lowStockCount: low,
      outOfStockCount: out,
      topProductsByQty: top.take(5).toList(),
    );
  }
}
