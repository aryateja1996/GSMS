import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/khata/domain/entities/khata_transaction.dart';

class CustomerKhataSummary {
  const CustomerKhataSummary({
    required this.customerId,
    required this.customerName,
    required this.outstanding,
    required this.phone,
  });

  final String customerId;
  final String customerName;
  final double outstanding;
  final String? phone;
}

abstract class KhataRepository {
  Future<double> getOutstanding(String customerId);

  Future<List<KhataTransaction>> getStatement(String customerId);

  Future<List<CustomerKhataSummary>> listCustomerSummaries({String? query});

  Future<Result<KhataTransaction>> recordPayment({
    required String customerId,
    required double amount,
    String? description,
  });

  Future<Result<KhataTransaction>> recordCreditSale({
    required String customerId,
    required double amount,
    required String referenceId,
    String? description,
  });

  Future<Result<KhataTransaction>> recordOpeningBalance({
    required String customerId,
    required double amount,
  });
}
