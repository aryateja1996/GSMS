import 'package:gsma/core/constants/unit_types.dart';
import 'package:gsma/core/database/collections/product_isar.dart';
import 'package:gsma/core/sync/sync_status.dart';
import 'package:gsma/features/products/domain/entities/product.dart';

abstract final class ProductMapper {
  static Product toEntity(ProductIsar model) {
    return Product(
      id: model.id,
      storeId: model.storeId,
      name: model.name,
      barcode: model.barcode,
      sku: model.sku,
      categoryId: model.categoryId,
      brand: model.brand,
      description: model.description,
      unitType: UnitTypeX.fromString(model.unitType),
      baseUnit: model.baseUnit,
      conversionFactor: model.conversionFactor,
      purchasePrice: model.purchasePrice,
      sellingPrice: model.sellingPrice,
      mrp: model.mrp,
      taxRate: model.taxRate,
      discount: model.discount,
      minimumStock: model.minimumStock,
      maximumStock: model.maximumStock,
      supplierId: model.supplierId,
      hasExpiry: model.hasExpiry,
      hasBatch: model.hasBatch,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static ProductIsar toIsar(Product entity, {String? deviceId}) {
    return ProductIsar()
      ..id = entity.id
      ..storeId = entity.storeId
      ..name = entity.name
      ..barcode = entity.barcode
      ..sku = entity.sku
      ..categoryId = entity.categoryId
      ..brand = entity.brand
      ..description = entity.description
      ..unitType = entity.unitType.name
      ..baseUnit = entity.baseUnit
      ..conversionFactor = entity.conversionFactor
      ..purchasePrice = entity.purchasePrice
      ..sellingPrice = entity.sellingPrice
      ..mrp = entity.mrp
      ..taxRate = entity.taxRate
      ..discount = entity.discount
      ..minimumStock = entity.minimumStock
      ..maximumStock = entity.maximumStock
      ..supplierId = entity.supplierId
      ..hasExpiry = entity.hasExpiry
      ..hasBatch = entity.hasBatch
      ..isActive = entity.isActive
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..sync.syncStatus = SyncStatus.pending.name
      ..sync.deviceId = deviceId ?? ''
      ..sync.version = 1;
  }
}
