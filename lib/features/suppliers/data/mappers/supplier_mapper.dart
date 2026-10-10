import 'package:gsma/core/database/collections/supplier_isar.dart';
import 'package:gsma/core/sync/sync_status.dart';
import 'package:gsma/features/suppliers/domain/entities/supplier.dart';

abstract final class SupplierMapper {
  static Supplier toEntity(SupplierIsar m) => Supplier(
        id: m.id,
        storeId: m.storeId,
        name: m.name,
        businessName: m.businessName,
        phone: m.phone,
        email: m.email,
        address: m.address,
        gstNumber: m.gstNumber,
        openingBalance: m.openingBalance,
        creditLimit: m.creditLimit,
        paymentTerms: m.paymentTerms,
        createdAt: m.createdAt,
        updatedAt: m.updatedAt,
      );

  static SupplierIsar toIsar(Supplier e) => SupplierIsar()
    ..id = e.id
    ..storeId = e.storeId
    ..name = e.name
    ..businessName = e.businessName
    ..phone = e.phone
    ..email = e.email
    ..address = e.address
    ..gstNumber = e.gstNumber
    ..openingBalance = e.openingBalance
    ..creditLimit = e.creditLimit
    ..paymentTerms = e.paymentTerms
    ..createdAt = e.createdAt
    ..updatedAt = e.updatedAt
    ..sync.syncStatus = SyncStatus.pending.name;
}
