enum StockMovementType {
  purchase,
  sale,
  saleReturn,
  purchaseReturn,
  adjustmentIn,
  adjustmentOut,
  damage,
  expired,
  transferIn,
  transferOut,
}

extension StockMovementTypeX on StockMovementType {
  String get code => name;

  static StockMovementType fromString(String value) {
    return StockMovementType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => StockMovementType.adjustmentIn,
    );
  }

  bool get increasesStock {
    switch (this) {
      case StockMovementType.purchase:
      case StockMovementType.saleReturn:
      case StockMovementType.adjustmentIn:
      case StockMovementType.transferIn:
        return true;
      case StockMovementType.sale:
      case StockMovementType.purchaseReturn:
      case StockMovementType.adjustmentOut:
      case StockMovementType.damage:
      case StockMovementType.expired:
      case StockMovementType.transferOut:
        return false;
    }
  }
}
