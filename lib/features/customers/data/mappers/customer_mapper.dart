import 'package:gsma/core/database/collections/customer_isar.dart';
import 'package:gsma/core/sync/sync_status.dart';
import 'package:gsma/features/customers/domain/entities/customer.dart';

abstract final class CustomerMapper {
  static Customer toEntity(CustomerIsar m) => Customer(
        id: m.id,
        storeId: m.storeId,
        name: m.name,
        phone: m.phone,
        email: m.email,
        address: m.address,
        openingBalance: m.openingBalance,
        creditLimit: m.creditLimit,
        isActive: m.isActive,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
      );

  static CustomerIsar toIsar(Customer e) => CustomerIsar()
    ..id = e.id
    ..storeId = e.storeId
    ..name = e.name
    ..phone = e.phone
    ..email = e.email
    ..address = e.address
    ..openingBalance = e.openingBalance
    ..creditLimit = e.creditLimit
    ..isActive = e.isActive
    ..createdAt = e.createdAt
    ..updatedAt = e.updatedAt
    ..sync.syncStatus = SyncStatus.pending.name;
}
