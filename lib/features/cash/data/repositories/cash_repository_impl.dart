import 'dart:convert';

import 'package:gsma/core/calculations/cash_calculator.dart';
import 'package:gsma/core/constants/khata_transaction_type.dart';
import 'package:gsma/core/constants/payment_methods.dart';
import 'package:gsma/core/database/collections/payment_isar.dart';
import 'package:gsma/core/database/collections/sale_isar.dart';
import 'package:gsma/core/database/datasources/local/app_settings_local_datasource.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/core/sync/sync_enqueue_service.dart';
import 'package:gsma/core/sync/sync_status.dart';
import 'package:gsma/core/utils/id_generator.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/cash/domain/repositories/cash_repository.dart';
import 'package:gsma/features/expenses/data/datasources/local/expense_local_datasource.dart';
import 'package:gsma/features/khata/data/datasources/local/khata_local_datasource.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

class CashRepositoryImpl implements CashRepository {
  CashRepositoryImpl(
    this._settings,
    this._isar,
    this._expenses,
    this._khata,
    this._store,
    this._syncEnqueue,
  );

  final AppSettingsLocalDataSource _settings;
  final IsarService _isar;
  final ExpenseLocalDataSource _expenses;
  final KhataLocalDataSource _khata;
  final StoreContext _store;
  final SyncEnqueueService _syncEnqueue;

  static String _dayKey(String prefix, String storeId, DateTime day) {
    final d = DateFormat('yyyy-MM-dd').format(day);
    return '$prefix${storeId}_$d';
  }

  static (DateTime start, DateTime end) _dayRange(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
    return (start, end);
  }

  @override
  Future<DailyCashSummary> getDailySummary(DateTime day) async {
    if (!_store.hasStore) {
      return CashCalculator.build(
        openingCash: 0,
        cashSales: 0,
        khataCollections: 0,
        otherCashIn: 0,
        cashExpenses: 0,
      );
    }

    final (start, end) = _dayRange(day);
    final storeId = _store.storeId;

    final opening = await _settings.readDouble(
          _dayKey('cash_opening_', storeId, day),
        ) ??
        0;

    final sales = await _isar.isar.saleIsars
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .saleDateBetween(start, end, includeLower: true, includeUpper: true)
        .findAll();

    final cashSales = sales
        .where((s) => s.paymentMethodSummary == PaymentMethod.cash.name)
        .fold(0.0, (sum, s) => sum + s.paidAmount);

    final khataTx = await _khata.listBetween(storeId, start, end);
    final khataCollections = khataTx
        .where((t) => t.type == KhataTransactionType.payment.name)
        .fold(0.0, (sum, t) => sum + t.amount);

    final payments = await _isar.isar.paymentIsars
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .partyTypeEqualTo('cash_in')
        .and()
        .paymentDateBetween(start, end, includeLower: true, includeUpper: true)
        .findAll();
    final otherCashIn = payments.fold(0.0, (sum, p) => sum + p.amount);

    final cashExpenses =
        await _expenses.sumCashExpensesBetween(storeId, start, end);

    final actual = await _settings.readDouble(
      _dayKey('cash_closing_actual_', storeId, day),
    );

    return CashCalculator.build(
      openingCash: opening,
      cashSales: cashSales,
      khataCollections: khataCollections,
      otherCashIn: otherCashIn,
      cashExpenses: cashExpenses,
      actualClosingCash: actual,
    );
  }

  @override
  Future<Result<void>> setOpeningCash(DateTime day, double amount) async {
    if (!_store.hasStore) {
      return const ErrorResult(CacheFailure('No store selected'));
    }
    if (amount < 0) {
      return const ErrorResult(ValidationFailure('Opening cash cannot be negative'));
    }
    await _settings.writeDouble(
      _dayKey('cash_opening_', _store.storeId, day),
      amount,
    );
    return const Success(null);
  }

  @override
  Future<Result<void>> recordOtherCashIn({
    required DateTime day,
    required double amount,
    String? description,
  }) async {
    if (!_store.hasStore) {
      return const ErrorResult(CacheFailure('No store selected'));
    }
    if (amount <= 0) {
      return const ErrorResult(ValidationFailure('Amount must be greater than zero'));
    }

    final now = DateTime.now();
    final id = IdGenerator.newId();
    final payment = PaymentIsar()
      ..id = id
      ..storeId = _store.storeId
      ..partyType = 'cash_in'
      ..partyId = _store.storeId
      ..amount = amount
      ..paymentMethod = PaymentMethod.cash.name
      ..description = description
      ..paymentDate = DateTime(day.year, day.month, day.day, now.hour, now.minute)
      ..createdBy = _store.userId
      ..createdAt = now
      ..sync.syncStatus = SyncStatus.pending.name;

    await _isar.isar.writeTxn(() async {
      await _isar.isar.paymentIsars.put(payment);
    });

    await _syncEnqueue.enqueue(
      storeId: _store.storeId,
      entityType: 'payments',
      entityId: id,
      action: 'create',
      payloadJson: jsonEncode({'id': id}),
    );
    return const Success(null);
  }

  @override
  Future<Result<void>> saveClosingCash(DateTime day, double actualAmount) async {
    if (!_store.hasStore) {
      return const ErrorResult(CacheFailure('No store selected'));
    }
    if (actualAmount < 0) {
      return const ErrorResult(ValidationFailure('Closing cash cannot be negative'));
    }
    await _settings.writeDouble(
      _dayKey('cash_closing_actual_', _store.storeId, day),
      actualAmount,
    );
    return const Success(null);
  }
}
