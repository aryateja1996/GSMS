import 'package:gsma/core/constants/stock_movement_type.dart';

class StockMovementQuantity {
  const StockMovementQuantity({required this.type, required this.quantity});

  final StockMovementType type;
  final double quantity;
}

abstract final class StockCalculator {
  static double balanceFromMovements(List<StockMovementQuantity> movements) {
    var balance = 0.0;
    for (final m in movements) {
      if (m.quantity <= 0) continue;
      if (m.type.increasesStock) {
        balance += m.quantity;
      } else {
        balance -= m.quantity;
      }
    }
    return balance;
  }
}
