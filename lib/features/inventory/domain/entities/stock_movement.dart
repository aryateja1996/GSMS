import 'package:equatable/equatable.dart';
import 'package:gsma/core/constants/stock_movement_type.dart';

class StockMovement extends Equatable {
  const StockMovement({
    required this.id,
    required this.storeId,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.unit,
    this.referenceId,
    this.reason,
    this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String storeId;
  final String productId;
  final StockMovementType type;
  final double quantity;
  final String unit;
  final String? referenceId;
  final String? reason;
  final String? createdBy;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, productId, type, quantity];
}
