import 'package:gsma/core/database/collections/khata_transaction_isar.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:isar/isar.dart';

class KhataLocalDataSource {
  KhataLocalDataSource(this._isar);

  final IsarService _isar;

  Future<List<KhataTransactionIsar>> forCustomer(
    String storeId,
    String customerId,
  ) async {
    return _isar.isar.khataTransactionIsars
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .customerIdEqualTo(customerId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<KhataTransactionIsar>> listBetween(
    String storeId,
    DateTime from,
    DateTime to,
  ) async {
    return _isar.isar.khataTransactionIsars
        .filter()
        .storeIdEqualTo(storeId)
        .and()
        .createdAtBetween(from, to, includeLower: true, includeUpper: true)
        .findAll();
  }

  Future<List<KhataTransactionIsar>> allForStore(String storeId) async {
    return _isar.isar.khataTransactionIsars
        .filter()
        .storeIdEqualTo(storeId)
        .sortByCreatedAtDesc()
        .limit(500)
        .findAll();
  }

  Future<void> save(KhataTransactionIsar tx) async {
    await _isar.isar.writeTxn(() async {
      await _isar.isar.khataTransactionIsars.put(tx);
    });
  }

  Future<void> saveAll(List<KhataTransactionIsar> list) async {
    await _isar.isar.writeTxn(() async {
      await _isar.isar.khataTransactionIsars.putAll(list);
    });
  }
}
