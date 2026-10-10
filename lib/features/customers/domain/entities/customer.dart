import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.storeId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.openingBalance = 0,
    this.creditLimit = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String storeId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final double openingBalance;
  final double creditLimit;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, name, phone];
}
