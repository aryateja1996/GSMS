import 'package:gsma/core/constants/stock_movement_type.dart';
import 'package:gsma/core/database/collections/stock_movement_isar.dart';
import 'package:gsma/core/sync/sync_status.dart';
import 'package:gsma/features/inventory/domain/entities/stock_movement.dart';

abstract final class StockMovementMapper {
  static StockMovement toEntity(StockMovementIsar model) {
    return StockMovement(
      id: model.id,
      storeId: model.storeId,
      productId: model.productId,
      type: StockMovementTypeX.fromString(model.type),
      quantity: model.quantity,
      unit: model.unit,
      referenceId: model.referenceId,
      reason: model.reason,
      createdBy: model.createdBy,
      createdAt: model.createdAt,
    );
  }

  static StockMovementIsar toIsar(StockMovement entity, {String? deviceId}) {
    return StockMovementIsar()
      ..id = entity.id
      ..storeId = entity.storeId
      ..productId = entity.productId
      ..type = entity.type.code
      ..quantity = entity.quantity
      ..unit = entity.unit
      ..referenceId = entity.referenceId
      ..reason = entity.reason
      ..createdBy = entity.createdBy
      ..createdAt = entity.createdAt
      ..sync.syncStatus = SyncStatus.pending.name
      ..sync.deviceId = deviceId ?? ''
      ..sync.version = 1;
  }
}
