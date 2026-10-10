import 'package:flutter_test/flutter_test.dart';
import 'package:gsma/core/calculations/khata_calculator.dart';
import 'package:gsma/core/constants/khata_transaction_type.dart';

void main() {
  group('KhataCalculator.outstandingFromLedger', () {
    test('sums credit and opening, subtracts payments', () {
      final balance = KhataCalculator.outstandingFromLedger([
        const KhataLedgerEntry(
          type: KhataTransactionType.openingBalance,
          amount: 100,
        ),
        const KhataLedgerEntry(
          type: KhataTransactionType.creditSale,
          amount: 50,
        ),
        const KhataLedgerEntry(
          type: KhataTransactionType.payment,
          amount: 30,
        ),
      ]);
      expect(balance, 120);
    });

    test('adjustment uses signed amount as-is', () {
      final balance = KhataCalculator.outstandingFromLedger([
        const KhataLedgerEntry(
          type: KhataTransactionType.adjustment,
          amount: -10,
        ),
      ]);
      expect(balance, -10);
    });
  });
}
