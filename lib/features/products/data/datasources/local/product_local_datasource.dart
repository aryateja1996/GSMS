import 'package:gsma/core/database/collections/product_isar.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:isar/isar.dart';

class ProductLocalDataSource {
  ProductLocalDataSource(this._isar);

  final IsarService _isar;

  Future<List<ProductIsar>> listActive(
    String storeId, {
    String? categoryId,
    String? query,
    int limit = 100,
    int offset = 0,
  }) async {
    var q = _isar.isar.productIsars
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .isActiveEqualTo(true);

    if (categoryId != null && categoryId.isNotEmpty) {
      q = q.and().categoryIdEqualTo(categoryId);
    }

    if (query != null && query.trim().isNotEmpty) {
      final term = query.trim();
      q = q.and().group((g) => g
          .nameContains(term, caseSensitive: false)
          .or()
          .barcodeContains(term, caseSensitive: false)
          .or()
          .skuContains(term, caseSensitive: false));
    }

    return q.sortByName().offset(offset).limit(limit).findAll();
  }

  Future<ProductIsar?> getById(String id) async {
    return _isar.isar.productIsars.filter().idEqualTo(id).findFirst();
  }

  Future<ProductIsar?> getByBarcode(String storeId, String barcode) async {
    return _isar.isar.productIsars
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .barcodeEqualTo(barcode)
        .and()
        .isActiveEqualTo(true)
        .findFirst();
  }

  Future<void> save(ProductIsar product) async {
    await _isar.isar.writeTxn(() async {
      await _isar.isar.productIsars.put(product);
    });
  }
}
