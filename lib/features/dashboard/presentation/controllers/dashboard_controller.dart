import 'package:get/get.dart';
import 'package:gsma/features/reports/domain/repositories/reports_repository.dart';

class DashboardController extends GetxController {
  DashboardController(this._reports);

  final ReportsRepository _reports;

  final RxBool isLoading = false.obs;
  final RxDouble todaySales = 0.0.obs;
  final RxDouble todayProfit = 0.0.obs;
  final RxInt lowStock = 0.obs;
  final RxDouble khataOutstanding = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshMetrics();
  }

  Future<void> refreshMetrics() async {
    isLoading.value = true;
    try {
      final overview = await _reports.businessOverview(ReportPeriod.today);
      todaySales.value = overview.salesTotal;
      todayProfit.value = overview.profit.netOperatingProfit;
      lowStock.value = overview.lowStockCount;
      khataOutstanding.value = overview.khataOutstanding;
    } catch (_) {
      // Dashboard stays with last values / zeros.
    } finally {
      isLoading.value = false;
    }
  }
}
