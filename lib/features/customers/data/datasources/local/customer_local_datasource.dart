import 'package:gsma/core/database/collections/customer_isar.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:isar/isar.dart';

class CustomerLocalDataSource {
  CustomerLocalDataSource(this._isar);

  final IsarService _isar;

  Future<List<CustomerIsar>> listActive(String storeId, {String? query}) async {
    var q = _isar.isar.customerIsars
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .isActiveEqualTo(true);
    if (query != null && query.trim().isNotEmpty) {
      final term = query.trim();
      q = q.and().group((g) => g
          .nameContains(term, caseSensitive: false)
          .or()
          .phoneContains(term, caseSensitive: false));
    }
    return q.sortByName().findAll();
  }

  Future<CustomerIsar?> getById(String id) async {
    return _isar.isar.customerIsars.filter().idEqualTo(id).findFirst();
  }

  Future<void> save(CustomerIsar customer) async {
    await _isar.isar.writeTxn(() async {
      await _isar.isar.customerIsars.put(customer);
    });
  }
}
