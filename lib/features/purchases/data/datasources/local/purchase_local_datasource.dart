import 'package:gsma/core/database/collections/purchase_isar.dart';
import 'package:gsma/core/database/collections/purchase_item_isar.dart';
import 'package:gsma/core/database/collections/stock_movement_isar.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:isar/isar.dart';

class PurchaseLocalDataSource {
  PurchaseLocalDataSource(this._isar);

  final IsarService _isar;

  Future<List<PurchaseIsar>> listRecent(String storeId, {int limit = 50}) async {
    return _isar.isar.purchaseIsars
        .filter()
        .storeIdEqualTo(storeId)
        .sortByPurchaseDateDesc()
        .limit(limit)
        .findAll();
  }

  Future<List<PurchaseItemIsar>> itemsForPurchase(String purchaseId) async {
    return _isar.isar.purchaseItemIsars
        .filter()
        .purchaseIdEqualTo(purchaseId)
        .findAll();
  }

  Future<double> supplierOutstanding(String storeId, String supplierId) async {
    final purchases = await _isar.isar.purchaseIsars
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .supplierIdEqualTo(supplierId)
        .findAll();
    return purchases.fold<double>(0, (sum, p) => sum + p.dueAmount);
  }

  Future<void> savePurchaseTransaction({
    required PurchaseIsar purchase,
    required List<PurchaseItemIsar> items,
    required List<StockMovementIsar> stockMovements,
  }) async {
    await _isar.isar.writeTxn(() async {
      await _isar.isar.purchaseIsars.put(purchase);
      await _isar.isar.purchaseItemIsars.putAll(items);
      await _isar.isar.stockMovementIsars.putAll(stockMovements);
    });
  }

  Future<void> updatePurchase(PurchaseIsar purchase) async {
    await _isar.isar.writeTxn(() async {
      await _isar.isar.purchaseIsars.put(purchase);
    });
  }

  Future<PurchaseIsar?> getById(String id) async {
    return _isar.isar.purchaseIsars.filter().idEqualTo(id).findFirst();
  }
}
