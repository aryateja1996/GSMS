import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/purchases/domain/entities/purchase.dart';

class CreatePurchaseInput {
  const CreatePurchaseInput({
    required this.supplierId,
    required this.invoiceNumber,
    required this.lines,
    this.discount = 0,
    this.tax = 0,
    this.paidAmount = 0,
  });

  final String supplierId;
  final String invoiceNumber;
  final List<CreatePurchaseLineInput> lines;
  final double discount;
  final double tax;
  final double paidAmount;
}

class CreatePurchaseLineInput {
  const CreatePurchaseLineInput({
    required this.productId,
    required this.quantity,
    required this.rate,
  });

  final String productId;
  final double quantity;
  final double rate;
}

abstract class PurchaseRepository {
  Future<List<Purchase>> listPurchases({int limit = 50});

  Future<Result<Purchase>> createPurchase(CreatePurchaseInput input);

  Future<Result<Purchase>> recordSupplierPayment({
    required String purchaseId,
    required double amount,
  });

  Future<double> getSupplierOutstanding(String supplierId);
}
