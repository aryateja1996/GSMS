import 'package:gsma/core/sync/sync_status.dart';
import 'package:gsma/features/expenses/domain/entities/expense.dart';
import 'package:gsma/core/database/collections/expense_isar.dart';

class ExpenseMapper {
  static Expense toEntity(ExpenseIsar model) {
    return Expense(
      id: model.id,
      storeId: model.storeId,
      category: model.category,
      amount: model.amount,
      paymentMethod: model.paymentMethod,
      description: model.description,
      date: model.date,
      createdBy: model.createdBy,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static ExpenseIsar toIsar(Expense entity) {
    return ExpenseIsar()
      ..id = entity.id
      ..storeId = entity.storeId
      ..category = entity.category
      ..amount = entity.amount
      ..paymentMethod = entity.paymentMethod
      ..description = entity.description
      ..date = entity.date
      ..createdBy = entity.createdBy
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..sync.syncStatus = SyncStatus.pending.name;
  }
}
