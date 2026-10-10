import 'package:gsma/core/database/collections/stock_movement_isar.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:isar/isar.dart';

class StockLocalDataSource {
  StockLocalDataSource(this._isar);

  final IsarService _isar;

  Future<List<StockMovementIsar>> movementsForProduct(
    String storeId,
    String productId, {
    int limit = 200,
  }) async {
    return _isar.isar.stockMovementIsars
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .productIdEqualTo(productId)
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }

  Future<List<StockMovementIsar>> recentMovements(
    String storeId, {
    int limit = 50,
  }) async {
    return _isar.isar.stockMovementIsars
        .filter()
        .storeIdEqualTo(storeId)
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }

  Future<void> saveMovement(StockMovementIsar movement) async {
    await _isar.isar.writeTxn(() async {
      await _isar.isar.stockMovementIsars.put(movement);
    });
  }

  Future<void> saveMovements(List<StockMovementIsar> movements) async {
    await _isar.isar.writeTxn(() async {
      await _isar.isar.stockMovementIsars.putAll(movements);
    });
  }
}
