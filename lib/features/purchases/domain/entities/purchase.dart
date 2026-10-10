import 'package:equatable/equatable.dart';

class PurchaseLine {
  const PurchaseLine({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.amount,
  });

  final String productId;
  final String productName;
  final double quantity;
  final String unit;
  final double rate;
  final double amount;
}

class Purchase extends Equatable {
  const Purchase({
    required this.id,
    required this.storeId,
    required this.supplierId,
    required this.supplierName,
    required this.invoiceNumber,
    required this.purchaseDate,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.paidAmount,
    required this.dueAmount,
    required this.paymentStatus,
    required this.lines,
    required this.createdAt,
  });

  final String id;
  final String storeId;
  final String supplierId;
  final String supplierName;
  final String invoiceNumber;
  final DateTime purchaseDate;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final double paidAmount;
  final double dueAmount;
  final String paymentStatus;
  final List<PurchaseLine> lines;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, invoiceNumber];
}
