import 'package:gsma/core/database/collections/category_isar.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:isar/isar.dart';

class CategoryLocalDataSource {
  CategoryLocalDataSource(this._isar);

  final IsarService _isar;

  Future<List<CategoryIsar>> listActive(String storeId) async {
    return _isar.isar.categoryIsars
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .isActiveEqualTo(true)
        .sortByName()
        .findAll();
  }

  Future<CategoryIsar?> getById(String id) async {
    return _isar.isar.categoryIsars.filter().idEqualTo(id).findFirst();
  }

  Future<void> save(CategoryIsar category) async {
    await _isar.isar.writeTxn(() async {
      await _isar.isar.categoryIsars.put(category);
    });
  }

  Future<int> countForStore(String storeId) async {
    return _isar.isar.categoryIsars
        .filter()
        .storeIdEqualTo(storeId)
        .count();
  }
}
