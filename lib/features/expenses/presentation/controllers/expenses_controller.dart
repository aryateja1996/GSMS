import 'package:get/get.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/expenses/domain/entities/expense.dart';
import 'package:gsma/features/expenses/domain/repositories/expense_repository.dart';

class ExpensesController extends GetxController {
  ExpensesController(this._expenses);

  final ExpenseRepository _expenses;

  final RxList<Expense> items = <Expense>[].obs;
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
      final now = DateTime.now();
      final from = DateTime(now.year, now.month, 1);
      items.assignAll(await _expenses.listExpenses(from: from, to: now));
    } catch (_) {
      errorMessage.value = 'Could not load expenses';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> save(SaveExpenseInput input) async {
    isLoading.value = true;
    final result = await _expenses.saveExpense(input);
    isLoading.value = false;
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
