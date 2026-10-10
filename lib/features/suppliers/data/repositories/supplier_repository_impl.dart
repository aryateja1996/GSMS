import 'dart:convert';

import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/core/sync/sync_enqueue_service.dart';
import 'package:gsma/core/utils/id_generator.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/suppliers/data/datasources/local/supplier_local_datasource.dart';
import 'package:gsma/features/suppliers/data/mappers/supplier_mapper.dart';
import 'package:gsma/features/suppliers/domain/entities/supplier.dart';
import 'package:gsma/features/suppliers/domain/repositories/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  SupplierRepositoryImpl(this._local, this._store, this._syncEnqueue);

  final SupplierLocalDataSource _local;
  final StoreContext _store;
  final SyncEnqueueService _syncEnqueue;

  @override
  Future<List<Supplier>> listSuppliers({String? query}) async {
    final list = await _local.list(_store.storeId, query: query);
    return list.map(SupplierMapper.toEntity).toList();
  }

  @override
  Future<Supplier?> getById(String id) async {
    final m = await _local.getById(id);
    return m == null ? null : SupplierMapper.toEntity(m);
  }

  @override
  Future<Result<Supplier>> saveSupplier(Supplier supplier) async {
    if (!_store.hasStore) {
      return const ErrorResult(CacheFailure('No store selected'));
    }
    final now = DateTime.now();
    final isNew = supplier.id.isEmpty;
    final entity = Supplier(
      id: isNew ? IdGenerator.newId() : supplier.id,
      storeId: _store.storeId,
      name: supplier.name.trim(),
      businessName: supplier.businessName?.trim(),
      phone: supplier.phone?.trim(),
      email: supplier.email?.trim(),
      address: supplier.address?.trim(),
      gstNumber: supplier.gstNumber?.trim(),
      openingBalance: supplier.openingBalance,
      creditLimit: supplier.creditLimit,
      paymentTerms: supplier.paymentTerms,
      createdAt: isNew ? now : supplier.createdAt,
      updatedAt: now,
    );
    await _local.save(SupplierMapper.toIsar(entity));
    await _syncEnqueue.enqueue(
      storeId: _store.storeId,
      entityType: 'suppliers',
      entityId: entity.id,
      action: isNew ? 'create' : 'update',
      payloadJson: jsonEncode({'id': entity.id}),
    );
    return Success(entity);
  }
}
