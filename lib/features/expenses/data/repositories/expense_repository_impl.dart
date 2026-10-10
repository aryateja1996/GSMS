import 'dart:convert';

import 'package:gsma/core/audit/audit_log_service.dart';
import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/core/sync/sync_enqueue_service.dart';
import 'package:gsma/core/utils/id_generator.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/expenses/data/datasources/local/expense_local_datasource.dart';
import 'package:gsma/features/expenses/data/mappers/expense_mapper.dart';
import 'package:gsma/features/expenses/domain/entities/expense.dart';
import 'package:gsma/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this._local, this._store, this._syncEnqueue);

  final ExpenseLocalDataSource _local;
  final StoreContext _store;
  final SyncEnqueueService _syncEnqueue;

  @override
  Future<List<Expense>> listExpenses({
    DateTime? from,
    DateTime? to,
    int limit = 200,
  }) async {
    final rows = await _local.listForStore(
      _store.storeId,
      from: from,
      to: to,
      limit: limit,
    );
    return rows.map(ExpenseMapper.toEntity).toList();
  }

  @override
  Future<Result<Expense>> saveExpense(SaveExpenseInput input) async {
    if (!_store.hasStore) {
      return const ErrorResult(CacheFailure('No store selected'));
    }
    if (input.amount <= 0) {
      return const ErrorResult(ValidationFailure('Amount must be greater than zero'));
    }
    if (input.category.trim().isEmpty) {
      return const ErrorResult(ValidationFailure('Category is required'));
    }

    final now = DateTime.now();
    final entity = Expense(
      id: IdGenerator.newId(),
      storeId: _store.storeId,
      category: input.category.trim(),
      amount: input.amount,
      paymentMethod: input.paymentMethod,
      description: input.description?.trim(),
      date: input.date,
      createdBy: _store.userId,
      createdAt: now,
      updatedAt: now,
    );

    final isar = ExpenseMapper.toIsar(entity);
    await _local.save(isar);
    await _syncEnqueue.enqueue(
      storeId: _store.storeId,
      entityType: 'expenses',
      entityId: entity.id,
      action: 'create',
      payloadJson: jsonEncode({'id': entity.id}),
    );
    await AuditLogService.optional?.record(
      action: 'expense_created',
      entityType: 'expense',
      entityId: entity.id,
      newValue: {'category': entity.category, 'amount': entity.amount},
    );
    return Success(entity);
  }
}
