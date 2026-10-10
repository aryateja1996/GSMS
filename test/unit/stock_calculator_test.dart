import 'package:flutter_test/flutter_test.dart';
import 'package:gsma/core/calculations/stock_calculator.dart';
import 'package:gsma/core/constants/stock_movement_type.dart';

void main() {
  test('balance from mixed movements', () {
    final balance = StockCalculator.balanceFromMovements([
      const StockMovementQuantity(
        type: StockMovementType.adjustmentIn,
        quantity: 10,
      ),
      const StockMovementQuantity(
        type: StockMovementType.sale,
        quantity: 3,
      ),
    ]);
    expect(balance, 7);
  });
}
