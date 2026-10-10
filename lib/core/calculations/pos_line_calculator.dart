/// POS line and bill totals (tax on amount after line discount).
class PosLineCalculator {
  static double lineAmount({
    required double quantity,
    required double rate,
    required double lineDiscount,
    required double taxRatePercent,
  }) {
    final gross = quantity * rate;
    final afterDiscount = gross - lineDiscount;
    if (afterDiscount <= 0) return 0;
    final tax = afterDiscount * (taxRatePercent / 100);
    return afterDiscount + tax;
  }

  static double lineTax({
    required double quantity,
    required double rate,
    required double lineDiscount,
    required double taxRatePercent,
  }) {
    final gross = quantity * rate;
    final afterDiscount = gross - lineDiscount;
    if (afterDiscount <= 0) return 0;
    return afterDiscount * (taxRatePercent / 100);
  }

  static BillTotals billTotals({
    required List<({double qty, double rate, double lineDiscount, double taxRate})> lines,
    double billDiscount = 0,
  }) {
    var subtotal = 0.0;
    var tax = 0.0;
    for (final line in lines) {
      final gross = line.qty * line.rate;
      subtotal += gross - line.lineDiscount;
      tax += lineTax(
        quantity: line.qty,
        rate: line.rate,
        lineDiscount: line.lineDiscount,
        taxRatePercent: line.taxRate,
      );
    }
    subtotal -= billDiscount;
    if (subtotal < 0) subtotal = 0;
    final total = subtotal + tax;
    return BillTotals(
      subtotal: subtotal,
      discount: billDiscount,
      tax: tax,
      total: total,
    );
  }
}

class BillTotals {
  const BillTotals({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
  });

  final double subtotal;
  final double discount;
  final double tax;
  final double total;
}
