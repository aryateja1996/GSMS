class ProfitSummary {
  const ProfitSummary({
    required this.grossSales,
    required this.discounts,
    required this.costOfGoodsSold,
    required this.expenses,
  });

  final double grossSales;
  final double discounts;
  final double costOfGoodsSold;
  final double expenses;

  double get netSales => grossSales - discounts;

  double get grossProfit => netSales - costOfGoodsSold;

  double get netOperatingProfit => grossProfit - expenses;

  double get profitMargin =>
      netSales <= 0 ? 0 : (netOperatingProfit / netSales) * 100;
}

abstract final class ProfitCalculator {
  static ProfitSummary summarize({
    required double grossSales,
    required double discounts,
    required double costOfGoodsSold,
    required double expenses,
  }) {
    return ProfitSummary(
      grossSales: grossSales,
      discounts: discounts,
      costOfGoodsSold: costOfGoodsSold,
      expenses: expenses,
    );
  }
}
