import 'package:gsma/core/calculations/profit_calculator.dart';
import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/features/expenses/data/datasources/local/expense_local_datasource.dart';
import 'package:gsma/features/reports/data/datasources/local/reports_local_datasource.dart';
import 'package:gsma/features/reports/domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl(this._reports, this._expenses, this._store);

  final ReportsLocalDataSource _reports;
  final ExpenseLocalDataSource _expenses;
  final StoreContext _store;

  @override
  (DateTime from, DateTime to) rangeFor(
    ReportPeriod period, {
    DateTime? customFrom,
    DateTime? customTo,
  }) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));

    switch (period) {
      case ReportPeriod.today:
        return (todayStart, todayEnd);
      case ReportPeriod.week:
        final from = todayStart.subtract(const Duration(days: 6));
        return (from, todayEnd);
      case ReportPeriod.month:
        final from = DateTime(now.year, now.month, 1);
        return (from, todayEnd);
      case ReportPeriod.year:
        final from = DateTime(now.year, 1, 1);
        return (from, todayEnd);
      case ReportPeriod.custom:
        final from = customFrom ?? todayStart;
        final to = customTo ?? todayEnd;
        return (from, to);
    }
  }

  @override
  Future<BusinessOverview> businessOverview(ReportPeriod period) async {
    final storeId = _store.storeId;
    final (from, to) = rangeFor(period);
    final sales = await _reports.salesTotals(storeId, from, to);
    final profit = await _reports.profitSummary(storeId, from, to);
    final inventory = await _reports.inventorySnapshot(storeId);
    final outstanding = await _reports.khataOutstanding(storeId);
    final expenseTotal = await _expenses.sumExpensesBetween(storeId, from, to);

    return BusinessOverview(
      salesTotal: sales.netTotal,
      profit: profit,
      khataOutstanding: outstanding,
      lowStockCount: inventory.lowStockCount + inventory.outOfStockCount,
      expenseTotal: expenseTotal,
    );
  }

  @override
  Future<SalesPeriodTotals> salesReport(ReportPeriod period) {
    final (from, to) = rangeFor(period);
    return _reports.salesTotals(_store.storeId, from, to);
  }

  @override
  Future<ProfitSummary> profitReport(ReportPeriod period) {
    final (from, to) = rangeFor(period);
    return _reports.profitSummary(_store.storeId, from, to);
  }

  @override
  Future<InventoryReportSnapshot> inventoryReport() =>
      _reports.inventorySnapshot(_store.storeId);

  @override
  Future<double> purchaseTotal(ReportPeriod period) {
    final (from, to) = rangeFor(period);
    return _reports.purchaseTotalBetween(_store.storeId, from, to);
  }

  @override
  Future<(double outstanding, double collections, double creditSales)> khataReport(
    ReportPeriod period,
  ) async {
    final storeId = _store.storeId;
    final (from, to) = rangeFor(period);
    final outstanding = await _reports.khataOutstanding(storeId);
    final collections = await _reports.khataCollectionsBetween(storeId, from, to);
    final creditSales = await _reports.creditSalesBetween(storeId, from, to);
    return (outstanding, collections, creditSales);
  }

  @override
  Future<Map<String, double>> expenseByCategory(ReportPeriod period) async {
    final (from, to) = rangeFor(period);
    final rows = await _expenses.listForStore(_store.storeId, from: from, to: to, limit: 5000);
    final map = <String, double>{};
    for (final e in rows) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }
}
