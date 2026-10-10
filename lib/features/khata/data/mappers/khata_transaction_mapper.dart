import 'package:gsma/core/constants/khata_transaction_type.dart';
import 'package:gsma/core/database/collections/khata_transaction_isar.dart';
import 'package:gsma/core/sync/sync_status.dart';
import 'package:gsma/features/khata/domain/entities/khata_transaction.dart';

abstract final class KhataTransactionMapper {
  static KhataTransaction toEntity(KhataTransactionIsar m) => KhataTransaction(
        id: m.id,
        storeId: m.storeId,
        customerId: m.customerId,
        type: KhataTransactionTypeX.fromString(m.type),
        amount: m.amount,
        referenceId: m.referenceId,
        description: m.description,
        balanceAfter: m.balanceAfter,
        createdBy: m.createdBy,
        createdAt: m.createdAt,
      );

  static KhataTransactionIsar toIsar(KhataTransaction e) => KhataTransactionIsar()
    ..id = e.id
    ..storeId = e.storeId
    ..customerId = e.customerId
    ..type = e.type.code
    ..amount = e.amount
    ..referenceId = e.referenceId
    ..description = e.description
    ..balanceAfter = e.balanceAfter
    ..createdBy = e.createdBy
    ..createdAt = e.createdAt
    ..sync.syncStatus = SyncStatus.pending.name;
}
