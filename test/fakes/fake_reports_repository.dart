import 'package:gsma/core/calculations/profit_calculator.dart';
import 'package:gsma/features/reports/data/datasources/local/reports_local_datasource.dart';
import 'package:gsma/features/reports/domain/repositories/reports_repository.dart';

class FakeReportsRepository implements ReportsRepository {
  @override
  (DateTime, DateTime) rangeFor(
    ReportPeriod period, {
    DateTime? customFrom,
    DateTime? customTo,
  }) {
    final now = DateTime.now();
    return (DateTime(now.year, now.month, now.day), now);
  }

  @override
  Future<BusinessOverview> businessOverview(ReportPeriod period) async {
    return BusinessOverview(
      salesTotal: 0,
      profit: ProfitCalculator.summarize(
        grossSales: 0,
        discounts: 0,
        costOfGoodsSold: 0,
        expenses: 0,
      ),
      khataOutstanding: 0,
      lowStockCount: 0,
      expenseTotal: 0,
    );
  }

  @override
  Future<SalesPeriodTotals> salesReport(ReportPeriod period) async {
    return const SalesPeriodTotals(
      saleCount: 0,
      grossSales: 0,
      discounts: 0,
      tax: 0,
      netTotal: 0,
      costOfGoodsSold: 0,
      byPaymentMethod: {},
      byProduct: {},
      byCategory: {},
    );
  }

  @override
  Future<ProfitSummary> profitReport(ReportPeriod period) async {
    return ProfitCalculator.summarize(
      grossSales: 0,
      discounts: 0,
      costOfGoodsSold: 0,
      expenses: 0,
    );
  }

  @override
  Future<InventoryReportSnapshot> inventoryReport() async {
    return const InventoryReportSnapshot(
      stockValue: 0,
      lowStockCount: 0,
      outOfStockCount: 0,
      topProductsByQty: [],
    );
  }

  @override
  Future<double> purchaseTotal(ReportPeriod period) async => 0;

  @override
  Future<(double, double, double)> khataReport(ReportPeriod period) async =>
      (0.0, 0.0, 0.0);

  @override
  Future<Map<String, double>> expenseByCategory(ReportPeriod period) async =>
      {};
}
