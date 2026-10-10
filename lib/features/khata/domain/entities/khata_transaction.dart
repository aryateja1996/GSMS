import 'package:equatable/equatable.dart';
import 'package:gsma/core/constants/khata_transaction_type.dart';

class KhataTransaction extends Equatable {
  const KhataTransaction({
    required this.id,
    required this.storeId,
    required this.customerId,
    required this.type,
    required this.amount,
    this.referenceId,
    this.description,
    required this.balanceAfter,
    this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String storeId;
  final String customerId;
  final KhataTransactionType type;
  final double amount;
  final String? referenceId;
  final String? description;
  final double balanceAfter;
  final String? createdBy;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, customerId, type, amount];
}
