import 'package:gsma/core/database/collections/expense_isar.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:isar/isar.dart';

class ExpenseLocalDataSource {
  ExpenseLocalDataSource(this._isar);

  final IsarService _isar;

  Future<List<ExpenseIsar>> listForStore(
    String storeId, {
    DateTime? from,
    DateTime? to,
    int limit = 200,
  }) async {
    if (from != null && to != null) {
      return _isar.isar.expenseIsars
          .filter()
          .storeIdEqualTo(storeId)
          .and()
          .dateBetween(from, to, includeLower: true, includeUpper: true)
          .sortByDateDesc()
          .limit(limit)
          .findAll();
    }
    if (from != null) {
      return _isar.isar.expenseIsars
          .filter()
          .storeIdEqualTo(storeId)
          .and()
          .dateGreaterThan(from, include: true)
          .sortByDateDesc()
          .limit(limit)
          .findAll();
    }
    if (to != null) {
      return _isar.isar.expenseIsars
          .filter()
          .storeIdEqualTo(storeId)
          .and()
          .dateLessThan(to, include: true)
          .sortByDateDesc()
          .limit(limit)
          .findAll();
    }
    return _isar.isar.expenseIsars
        .filter()
        .storeIdEqualTo(storeId)
        .sortByDateDesc()
        .limit(limit)
        .findAll();
  }

  Future<double> sumCashExpensesBetween(
    String storeId,
    DateTime from,
    DateTime to,
  ) async {
    final rows = await listForStore(storeId, from: from, to: to, limit: 10000);
    var total = 0.0;
    for (final e in rows) {
      if (e.paymentMethod == 'cash') total += e.amount;
    }
    return total;
  }

  Future<double> sumExpensesBetween(
    String storeId,
    DateTime from,
    DateTime to,
  ) async {
    final rows = await listForStore(storeId, from: from, to: to, limit: 10000);
    var total = 0.0;
    for (final e in rows) {
      total += e.amount;
    }
    return total;
  }

  Future<ExpenseIsar?> getById(String id) =>
      _isar.isar.expenseIsars.filter().idEqualTo(id).findFirst();

  Future<void> save(ExpenseIsar expense) async {
    await _isar.isar.writeTxn(() async {
      await _isar.isar.expenseIsars.put(expense);
    });
  }
}
