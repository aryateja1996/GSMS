import 'package:equatable/equatable.dart';
import 'package:gsma/core/constants/unit_types.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.storeId,
    required this.name,
    this.barcode,
    this.sku,
    required this.categoryId,
    this.brand,
    this.description,
    required this.unitType,
    required this.baseUnit,
    this.conversionFactor = 1,
    this.purchasePrice = 0,
    this.sellingPrice = 0,
    this.mrp = 0,
    this.taxRate = 0,
    this.discount = 0,
    this.minimumStock = 0,
    this.maximumStock = 0,
    this.supplierId,
    this.hasExpiry = false,
    this.hasBatch = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String storeId;
  final String name;
  final String? barcode;
  final String? sku;
  final String categoryId;
  final String? brand;
  final String? description;
  final UnitType unitType;
  final String baseUnit;
  final double conversionFactor;
  final double purchasePrice;
  final double sellingPrice;
  final double mrp;
  final double taxRate;
  final double discount;
  final double minimumStock;
  final double maximumStock;
  final String? supplierId;
  final bool hasExpiry;
  final bool hasBatch;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, storeId, name, barcode, isActive];
}
