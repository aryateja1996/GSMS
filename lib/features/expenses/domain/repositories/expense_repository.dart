import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/expenses/domain/entities/expense.dart';

class SaveExpenseInput {
  const SaveExpenseInput({
    required this.category,
    required this.amount,
    required this.paymentMethod,
    required this.date,
    this.description,
  });

  final String category;
  final double amount;
  final String paymentMethod;
  final String? description;
  final DateTime date;
}

abstract class ExpenseRepository {
  Future<List<Expense>> listExpenses({
    DateTime? from,
    DateTime? to,
    int limit = 200,
  });

  Future<Result<Expense>> saveExpense(SaveExpenseInput input);
}
