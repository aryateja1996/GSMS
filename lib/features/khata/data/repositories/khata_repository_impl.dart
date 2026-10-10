import 'dart:convert';

import 'package:gsma/core/calculations/khata_calculator.dart';
import 'package:gsma/core/constants/khata_transaction_type.dart';
import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/core/sync/sync_enqueue_service.dart';
import 'package:gsma/core/utils/id_generator.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/customers/data/datasources/local/customer_local_datasource.dart';
import 'package:gsma/features/khata/data/datasources/local/khata_local_datasource.dart';
import 'package:gsma/features/khata/data/mappers/khata_transaction_mapper.dart';
import 'package:gsma/features/khata/domain/entities/khata_transaction.dart';
import 'package:gsma/features/khata/domain/repositories/khata_repository.dart';

class KhataRepositoryImpl implements KhataRepository {
  KhataRepositoryImpl(
    this._khataLocal,
    this._customerLocal,
    this._store,
    this._syncEnqueue,
  );

  final KhataLocalDataSource _khataLocal;
  final CustomerLocalDataSource _customerLocal;
  final StoreContext _store;
  final SyncEnqueueService _syncEnqueue;

  Future<double> _computeOutstanding(String customerId) async {
    final txs = await _khataLocal.forCustomer(_store.storeId, customerId);
    return KhataCalculator.outstandingFromLedger(
      txs
          .map(
            (t) => KhataLedgerEntry(
              type: KhataTransactionTypeX.fromString(t.type),
              amount: t.amount,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<double> getOutstanding(String customerId) =>
      _computeOutstanding(customerId);

  @override
  Future<List<KhataTransaction>> getStatement(String customerId) async {
    final txs = await _khataLocal.forCustomer(_store.storeId, customerId);
    return txs.map(KhataTransactionMapper.toEntity).toList();
  }

  @override
  Future<List<CustomerKhataSummary>> listCustomerSummaries({
    String? query,
  }) async {
    final customers = await _customerLocal.listActive(_store.storeId, query: query);
    final summaries = <CustomerKhataSummary>[];
    for (final c in customers) {
      final outstanding = await _computeOutstanding(c.id);
      summaries.add(
        CustomerKhataSummary(
          customerId: c.id,
          customerName: c.name,
          outstanding: outstanding,
          phone: c.phone,
        ),
      );
    }
    summaries.sort((a, b) => b.outstanding.compareTo(a.outstanding));
    return summaries;
  }

  Future<Result<KhataTransaction>> _append({
    required String customerId,
    required KhataTransactionType type,
    required double amount,
    String? referenceId,
    String? description,
  }) async {
    if (!_store.hasStore) {
      return const ErrorResult(CacheFailure('No store selected'));
    }
    if (amount <= 0 && type != KhataTransactionType.adjustment) {
      return const ErrorResult(ValidationFailure('Amount must be greater than zero'));
    }

    final customer = await _customerLocal.getById(customerId);
    if (customer == null) {
      return const ErrorResult(CacheFailure('Customer not found'));
    }

    final current = await _computeOutstanding(customerId);
    final delta = type.signedAmount(amount);
    final balanceAfter = current + delta;

    if (balanceAfter < 0) {
      return const ErrorResult(ValidationFailure('Outstanding cannot go negative'));
    }
    if (customer.creditLimit > 0 && balanceAfter > customer.creditLimit) {
      return ErrorResult(
        ValidationFailure(
          'Credit limit exceeded (limit ${customer.creditLimit})',
        ),
      );
    }

    final entity = KhataTransaction(
      id: IdGenerator.newId(),
      storeId: _store.storeId,
      customerId: customerId,
      type: type,
      amount: amount.abs(),
      referenceId: referenceId,
      description: description,
      balanceAfter: balanceAfter,
      createdBy: _store.userId,
      createdAt: DateTime.now(),
    );

    await _khataLocal.save(KhataTransactionMapper.toIsar(entity));
    await _syncEnqueue.enqueue(
      storeId: _store.storeId,
      entityType: 'khataTransactions',
      entityId: entity.id,
      action: 'create',
      payloadJson: jsonEncode({'id': entity.id}),
    );
    return Success(entity);
  }

  @override
  Future<Result<KhataTransaction>> recordPayment({
    required String customerId,
    required double amount,
    String? description,
  }) =>
      _append(
        customerId: customerId,
        type: KhataTransactionType.payment,
        amount: amount,
        description: description ?? 'Payment received',
      );

  @override
  Future<Result<KhataTransaction>> recordCreditSale({
    required String customerId,
    required double amount,
    required String referenceId,
    String? description,
  }) =>
      _append(
        customerId: customerId,
        type: KhataTransactionType.creditSale,
        amount: amount,
        referenceId: referenceId,
        description: description ?? 'Credit sale',
      );

  @override
  Future<Result<KhataTransaction>> recordOpeningBalance({
    required String customerId,
    required double amount,
  }) async {
    if (amount <= 0) {
      return const ErrorResult(ValidationFailure('Opening balance must be positive'));
    }
    return _append(
      customerId: customerId,
      type: KhataTransactionType.openingBalance,
      amount: amount,
      description: 'Opening balance',
    );
  }
}
