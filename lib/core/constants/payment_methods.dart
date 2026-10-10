enum PaymentMethod {
  cash,
  upi,
  card,
  credit,
  split,
}

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.credit:
        return 'Credit / Khata';
      case PaymentMethod.split:
        return 'Split';
    }
  }

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (p) => p.name == value.toLowerCase(),
      orElse: () => PaymentMethod.cash,
    );
  }
}
