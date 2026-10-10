import 'package:flutter_test/flutter_test.dart';
import 'package:gsma/core/calculations/profit_calculator.dart';

void main() {
  test('net operating profit and margin', () {
    final p = ProfitCalculator.summarize(
      grossSales: 1000,
      discounts: 100,
      costOfGoodsSold: 400,
      expenses: 200,
    );
    expect(p.grossProfit, 500);
    expect(p.netOperatingProfit, 300);
    expect(p.profitMargin, closeTo(33.333, 0.01));
  });
}
