import 'package:gsma/core/database/collections/sale_isar.dart';
import 'package:gsma/core/database/collections/sale_item_isar.dart';
import 'package:gsma/core/database/collections/stock_movement_isar.dart';
import 'package:gsma/core/database/isar_service.dart';

class SaleLocalDataSource {
  SaleLocalDataSource(this._isar);

  final IsarService _isar;

  Future<void> saveSaleTransaction({
    required SaleIsar sale,
    required List<SaleItemIsar> items,
    required List<StockMovementIsar> stockMovements,
  }) async {
    await _isar.isar.writeTxn(() async {
      await _isar.isar.saleIsars.put(sale);
      await _isar.isar.saleItemIsars.putAll(items);
      await _isar.isar.stockMovementIsars.putAll(stockMovements);
    });
  }
}
