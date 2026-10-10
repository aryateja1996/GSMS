class DailyCashSummary {
  const DailyCashSummary({
    required this.openingCash,
    required this.cashSales,
    required this.khataCollections,
    required this.otherCashIn,
    required this.cashExpenses,
    required this.refunds,
    this.actualClosingCash,
  });

  final double openingCash;
  final double cashSales;
  final double khataCollections;
  final double otherCashIn;
  final double cashExpenses;
  final double refunds;
  final double? actualClosingCash;

  double get expectedClosingCash =>
      openingCash +
      cashSales +
      khataCollections +
      otherCashIn -
      cashExpenses -
      refunds;

  double? get variance =>
      actualClosingCash == null ? null : actualClosingCash! - expectedClosingCash;
}

abstract final class CashCalculator {
  static DailyCashSummary build({
    required double openingCash,
    required double cashSales,
    required double khataCollections,
    required double otherCashIn,
    required double cashExpenses,
    double refunds = 0,
    double? actualClosingCash,
  }) {
    return DailyCashSummary(
      openingCash: openingCash,
      cashSales: cashSales,
      khataCollections: khataCollections,
      otherCashIn: otherCashIn,
      cashExpenses: cashExpenses,
      refunds: refunds,
      actualClosingCash: actualClosingCash,
    );
  }
}
