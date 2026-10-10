import 'package:flutter_test/flutter_test.dart';
import 'package:gsma/core/calculations/pos_line_calculator.dart';

void main() {
  test('bill totals with tax after discount', () {
    final totals = PosLineCalculator.billTotals(
      lines: [
        (qty: 2.0, rate: 100.0, lineDiscount: 10.0, taxRate: 5.0),
      ],
    );
    expect(totals.subtotal, 190);
    expect(totals.tax, closeTo(9.5, 0.01));
    expect(totals.total, closeTo(199.5, 0.01));
  });
}
