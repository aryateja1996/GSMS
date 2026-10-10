import 'package:gsma/core/constants/stock_movement_type.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/inventory/domain/entities/stock_movement.dart';

class ProductStockSummary {
  const ProductStockSummary({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.minimumStock,
  });

  final String productId;
  final String productName;
  final String unit;
  final double quantity;
  final double minimumStock;

  bool get isLowStock => quantity <= minimumStock;
  bool get isOutOfStock => quantity <= 0;
}

abstract class InventoryRepository {
  Future<double> getStockQuantity(String productId);

  Future<Result<StockMovement>> recordMovement({
    required String productId,
    required StockMovementType type,
    required double quantity,
    required String unit,
    String? referenceId,
    String? reason,
  });

  Future<List<StockMovement>> recentMovements({int limit = 50});

  Future<List<ProductStockSummary>> listStockSummaries({String? query});
}
