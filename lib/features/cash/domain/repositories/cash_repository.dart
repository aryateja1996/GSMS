import 'package:gsma/core/calculations/cash_calculator.dart';
import 'package:gsma/core/utils/result.dart';

abstract class CashRepository {
  Future<DailyCashSummary> getDailySummary(DateTime day);

  Future<Result<void>> setOpeningCash(DateTime day, double amount);

  Future<Result<void>> recordOtherCashIn({
    required DateTime day,
    required double amount,
    String? description,
  });

  Future<Result<void>> saveClosingCash(DateTime day, double actualAmount);
}
