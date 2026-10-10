import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  const Supplier({
    required this.id,
    required this.storeId,
    required this.name,
    this.businessName,
    this.phone,
    this.email,
    this.address,
    this.gstNumber,
    this.openingBalance = 0,
    this.creditLimit = 0,
    this.paymentTerms,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String storeId;
  final String name;
  final String? businessName;
  final String? phone;
  final String? email;
  final String? address;
  final String? gstNumber;
  final double openingBalance;
  final double creditLimit;
  final String? paymentTerms;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, name, phone];
}
