import 'package:get/get.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/khata/domain/entities/khata_transaction.dart';
import 'package:gsma/features/khata/domain/repositories/khata_repository.dart';

class KhataController extends GetxController {
  KhataController(this._khata);

  final KhataRepository _khata;

  final RxList<CustomerKhataSummary> summaries = <CustomerKhataSummary>[].obs;
  final RxList<KhataTransaction> statement = <KhataTransaction>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxDouble totalOutstanding = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadSummaries();
  }

  Future<void> loadSummaries({String? query}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      summaries.assignAll(await _khata.listCustomerSummaries(query: query));
      totalOutstanding.value = summaries.fold(0, (s, e) => s + e.outstanding);
    } catch (e) {
      errorMessage.value = 'Could not load Khata';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStatement(String customerId) async {
    statement.assignAll(await _khata.getStatement(customerId));
  }

  Future<double> outstandingFor(String customerId) =>
      _khata.getOutstanding(customerId);

  Future<bool> receivePayment({
    required String customerId,
    required double amount,
  }) async {
    isLoading.value = true;
    final result = await _khata.recordPayment(
      customerId: customerId,
      amount: amount,
    );
    isLoading.value = false;
    switch (result) {
      case Success():
        await loadSummaries();
        await loadStatement(customerId);
        return true;
      case ErrorResult(failure: final failure):
        errorMessage.value = failure.message;
        return false;
    }
  }
}
