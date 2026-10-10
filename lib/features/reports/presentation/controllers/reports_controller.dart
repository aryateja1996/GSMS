import 'package:get/get.dart';
import 'package:gsma/core/calculations/profit_calculator.dart';
import 'package:gsma/features/reports/data/datasources/local/reports_local_datasource.dart';
import 'package:gsma/features/reports/domain/repositories/reports_repository.dart';

class ReportsController extends GetxController {
  ReportsController(this._reports);

  final ReportsRepository _reports;

  final Rx<ReportPeriod> period = ReportPeriod.month.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<SalesPeriodTotals> sales = Rxn<SalesPeriodTotals>();
  final Rxn<ProfitSummary> profit = Rxn<ProfitSummary>();
  final Rxn<InventoryReportSnapshot> inventory = Rxn<InventoryReportSnapshot>();
  final RxDouble purchaseTotal = 0.0.obs;
  final RxDouble khataOutstanding = 0.0.obs;
  final RxDouble khataCollections = 0.0.obs;
  final RxDouble creditSales = 0.0.obs;
  final RxMap<String, double> expensesByCategory = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      sales.value = await _reports.salesReport(period.value);
      profit.value = await _reports.profitReport(period.value);
      inventory.value = await _reports.inventoryReport();
      purchaseTotal.value = await _reports.purchaseTotal(period.value);
      final khata = await _reports.khataReport(period.value);
      khataOutstanding.value = khata.$1;
      khataCollections.value = khata.$2;
      creditSales.value = khata.$3;
      expensesByCategory.assignAll(await _reports.expenseByCategory(period.value));
    } catch (_) {
      errorMessage.value = 'Could not load reports';
    } finally {
      isLoading.value = false;
    }
  }

  void setPeriod(ReportPeriod p) {
    period.value = p;
    load();
  }
}
