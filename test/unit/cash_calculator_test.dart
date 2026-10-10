import 'package:flutter_test/flutter_test.dart';
import 'package:gsma/core/calculations/cash_calculator.dart';

void main() {
  test('expected closing cash from components', () {
    final summary = CashCalculator.build(
      openingCash: 1000,
      cashSales: 500,
      khataCollections: 200,
      otherCashIn: 50,
      cashExpenses: 150,
      refunds: 25,
    );
    expect(summary.expectedClosingCash, 1575);
  });
}
