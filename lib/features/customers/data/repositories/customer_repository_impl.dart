import 'dart:convert';

import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/core/sync/sync_enqueue_service.dart';
import 'package:gsma/core/utils/id_generator.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/customers/data/datasources/local/customer_local_datasource.dart';
import 'package:gsma/features/customers/data/mappers/customer_mapper.dart';
import 'package:gsma/features/customers/domain/entities/customer.dart';
import 'package:gsma/features/customers/domain/repositories/customer_repository.dart';
import 'package:gsma/features/khata/domain/repositories/khata_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(
    this._local,
    this._khata,
    this._store,
    this._syncEnqueue,
  );

  final CustomerLocalDataSource _local;
  final KhataRepository _khata;
  final StoreContext _store;
  final SyncEnqueueService _syncEnqueue;

  @override
  Future<List<Customer>> listCustomers({String? query}) async {
    final list = await _local.listActive(_store.storeId, query: query);
    return list.map(CustomerMapper.toEntity).toList();
  }

  @override
  Future<Customer?> getById(String id) async {
    final m = await _local.getById(id);
    return m == null ? null : CustomerMapper.toEntity(m);
  }

  @override
  Future<Result<Customer>> saveCustomer(Customer customer) async {
    if (!_store.hasStore) {
      return const ErrorResult(CacheFailure('No store selected'));
    }
    final now = DateTime.now();
    final isNew = customer.id.isEmpty;
    final entity = Customer(
      id: isNew ? IdGenerator.newId() : customer.id,
      storeId: _store.storeId,
      name: customer.name.trim(),
      phone: customer.phone?.trim(),
      email: customer.email?.trim(),
      address: customer.address?.trim(),
      openingBalance: customer.openingBalance,
      creditLimit: customer.creditLimit,
      isActive: customer.isActive,
      createdAt: isNew ? now : customer.createdAt,
      updatedAt: now,
    );

    await _local.save(CustomerMapper.toIsar(entity));
    await _syncEnqueue.enqueue(
      storeId: _store.storeId,
      entityType: 'customers',
      entityId: entity.id,
      action: isNew ? 'create' : 'update',
      payloadJson: jsonEncode({'id': entity.id}),
    );

    if (isNew && entity.openingBalance > 0) {
      final ob = await _khata.recordOpeningBalance(
        customerId: entity.id,
        amount: entity.openingBalance,
      );
      if (ob case ErrorResult(failure: final f)) {
        return ErrorResult(f);
      }
    }

    return Success(entity);
  }

  @override
  Future<Result<void>> deactivateCustomer(String id) async {
    final m = await _local.getById(id);
    if (m == null) return const ErrorResult(CacheFailure('Customer not found'));
    m.isActive = false;
    m.updatedAt = DateTime.now();
    await _local.save(m);
    return const Success(null);
  }
}
