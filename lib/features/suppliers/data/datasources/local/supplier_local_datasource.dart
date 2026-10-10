import 'package:gsma/core/database/collections/supplier_isar.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:isar/isar.dart';

class SupplierLocalDataSource {
  SupplierLocalDataSource(this._isar);

  final IsarService _isar;

  Future<List<SupplierIsar>> list(String storeId, {String? query}) async {
    var q = _isar.isar.supplierIsars.filter().storeIdEqualTo(storeId);
    if (query != null && query.trim().isNotEmpty) {
      final term = query.trim();
      q = q.and().group((g) => g
          .nameContains(term, caseSensitive: false)
          .or()
          .phoneContains(term, caseSensitive: false));
    }
    return q.sortByName().findAll();
  }

  Future<SupplierIsar?> getById(String id) async {
    return _isar.isar.supplierIsars.filter().idEqualTo(id).findFirst();
  }

  Future<void> save(SupplierIsar supplier) async {
    await _isar.isar.writeTxn(() async {
      await _isar.isar.supplierIsars.put(supplier);
    });
  }
}
