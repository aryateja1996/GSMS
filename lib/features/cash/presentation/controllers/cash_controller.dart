import 'package:get/get.dart';
import 'package:gsma/core/calculations/cash_calculator.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/cash/domain/repositories/cash_repository.dart';

class CashController extends GetxController {
  CashController(this._cash);

  final CashRepository _cash;

  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final Rxn<DailyCashSummary> summary = Rxn<DailyCashSummary>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      summary.value = await _cash.getDailySummary(selectedDay.value);
    } catch (_) {
      errorMessage.value = 'Could not load cash summary';
    } finally {
      isLoading.value = false;
    }
  }

  void pickDay(DateTime day) {
    selectedDay.value = DateTime(day.year, day.month, day.day);
    load();
  }

  Future<bool> setOpening(double amount) async {
    final result = await _cash.setOpeningCash(selectedDay.value, amount);
    return _handleResult(result);
  }

  Future<bool> addOtherIn(double amount, {String? description}) async {
    final result = await _cash.recordOtherCashIn(
      day: selectedDay.value,
      amount: amount,
      description: description,
    );
    return _handleResult(result);
  }

  Future<bool> saveClosing(double amount) async {
    final result = await _cash.saveClosingCash(selectedDay.value, amount);
    return _handleResult(result);
  }

  Future<bool> _handleResult(Result<void> result) async {
    switch (result) {
      case Success():
        await load();
        return true;
      case ErrorResult(failure: final f):
        errorMessage.value = f.message;
        return false;
    }
  }
}
