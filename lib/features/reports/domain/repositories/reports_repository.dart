import 'package:gsma/core/calculations/profit_calculator.dart';
import 'package:gsma/features/reports/data/datasources/local/reports_local_datasource.dart';

enum ReportPeriod { today, week, month, year, custom }

class BusinessOverview {
  const BusinessOverview({
    required this.salesTotal,
    required this.profit,
    required this.khataOutstanding,
    required this.lowStockCount,
    required this.expenseTotal,
  });

  final double salesTotal;
  final ProfitSummary profit;
  final double khataOutstanding;
  final int lowStockCount;
  final double expenseTotal;
}

abstract class ReportsRepository {
  (DateTime from, DateTime to) rangeFor(ReportPeriod period, {DateTime? customFrom, DateTime? customTo});

  Future<BusinessOverview> businessOverview(ReportPeriod period);

  Future<SalesPeriodTotals> salesReport(ReportPeriod period);

  Future<ProfitSummary> profitReport(ReportPeriod period);

  Future<InventoryReportSnapshot> inventoryReport();

  Future<double> purchaseTotal(ReportPeriod period);

  Future<(double outstanding, double collections, double creditSales)> khataReport(
    ReportPeriod period,
  );

  Future<Map<String, double>> expenseByCategory(ReportPeriod period);
}
