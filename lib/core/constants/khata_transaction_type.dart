enum KhataTransactionType {
  creditSale,
  payment,
  saleReturn,
  adjustment,
  openingBalance,
}

extension KhataTransactionTypeX on KhataTransactionType {
  String get code => name;

  static KhataTransactionType fromString(String value) {
    return KhataTransactionType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => KhataTransactionType.adjustment,
    );
  }

  /// Positive increases customer outstanding; negative decreases it.
  double signedAmount(double amount) {
    switch (this) {
      case KhataTransactionType.creditSale:
      case KhataTransactionType.openingBalance:
        return amount.abs();
      case KhataTransactionType.payment:
      case KhataTransactionType.saleReturn:
        return -amount.abs();
      case KhataTransactionType.adjustment:
        return amount;
    }
  }
}
