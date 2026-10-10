import 'package:gsma/core/constants/khata_transaction_type.dart';

class KhataLedgerEntry {
  const KhataLedgerEntry({required this.type, required this.amount});

  final KhataTransactionType type;
  final double amount;
}

abstract final class KhataCalculator {
  static double outstandingFromLedger(List<KhataLedgerEntry> entries) {
    var balance = 0.0;
    for (final e in entries) {
      balance += e.type.signedAmount(e.amount);
    }
    return balance;
  }
}
