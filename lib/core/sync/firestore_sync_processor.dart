import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gsma/core/database/collections/audit_log_isar.dart';
import 'package:gsma/core/database/collections/category_isar.dart';
import 'package:gsma/core/database/collections/customer_isar.dart';
import 'package:gsma/core/database/collections/expense_isar.dart';
import 'package:gsma/core/database/collections/khata_transaction_isar.dart';
import 'package:gsma/core/database/collections/payment_isar.dart';
import 'package:gsma/core/database/collections/product_isar.dart';
import 'package:gsma/core/database/collections/purchase_isar.dart';
import 'package:gsma/core/database/collections/sale_isar.dart';
import 'package:gsma/core/database/collections/stock_movement_isar.dart';
import 'package:gsma/core/database/collections/supplier_isar.dart';
import 'package:gsma/core/database/collections/purchase_item_isar.dart';
import 'package:gsma/core/database/collections/sale_item_isar.dart';
import 'package:gsma/core/database/collections/sync_queue_item.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:gsma/core/sync/device_id_service.dart';
import 'package:gsma/core/sync/sync_status.dart';
import 'package:gsma/core/utils/app_logger.dart';
import 'package:isar/isar.dart';

class FirestoreSyncProcessor {
  FirestoreSyncProcessor(this._isar, this._deviceId);

  final IsarService _isar;
  final DeviceIdService _deviceId;

  static const _maxAttempts = 5;

  bool get canSync => Firebase.apps.isNotEmpty;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<int> processPendingQueue() async {
    if (!canSync || !_isar.isReady) return 0;

    final pending = await _isar.isar.syncQueueItems
        .where()
        .syncStatusEqualTo(SyncStatus.pending.name)
        .sortByCreatedAt()
        .findAll();

    var processed = 0;
    for (final item in pending) {
      final ok = await _processOne(item);
      if (ok) processed++;
    }
    return processed;
  }

  Future<bool> _processOne(SyncQueueItem item) async {
    item.syncStatus = SyncStatus.syncing.name;
    item.updatedAt = DateTime.now();
    await _isar.isar.writeTxn(() async {
      await _isar.isar.syncQueueItems.put(item);
    });

    try {
      final payload = await _buildDocument(item);
      if (payload == null) {
        throw StateError('Entity ${item.entityType}/${item.entityId} not found locally');
      }

      final collection = _collectionFor(item.entityType);
      await _db.collection(collection).doc(item.entityId).set(
            payload,
            SetOptions(merge: true),
          );

      await _markEntitySynced(item.entityType, item.entityId);
      item.syncStatus = SyncStatus.synced.name;
      item.lastError = null;
      item.updatedAt = DateTime.now();
      await _isar.isar.writeTxn(() async {
        await _isar.isar.syncQueueItems.put(item);
      });
      return true;
    } catch (e, st) {
      AppLogger.warning('Sync failed ${item.entityType}/${item.entityId}: $e', tag: 'Sync');
      AppLogger.warning('$st', tag: 'Sync');
      item.attemptCount += 1;
      item.lastError = e.toString();
      item.syncStatus = item.attemptCount >= _maxAttempts
          ? SyncStatus.failed.name
          : SyncStatus.pending.name;
      item.updatedAt = DateTime.now();
      await _isar.isar.writeTxn(() async {
        await _isar.isar.syncQueueItems.put(item);
      });
      return false;
    }
  }

  String _collectionFor(String entityType) {
    switch (entityType) {
      case 'products':
        return 'products';
      case 'categories':
        return 'categories';
      case 'customers':
        return 'customers';
      case 'suppliers':
        return 'suppliers';
      case 'sales':
        return 'sales';
      case 'purchases':
        return 'purchases';
      case 'stockMovements':
        return 'stockMovements';
      case 'khataTransactions':
        return 'khataTransactions';
      case 'expenses':
        return 'expenses';
      case 'payments':
        return 'payments';
      case 'auditLogs':
        return 'auditLogs';
      default:
        return entityType;
    }
  }

  Map<String, dynamic> _syncMeta(String storeId) => {
        'storeId': storeId,
        'syncStatus': SyncStatus.synced.name,
        'deviceId': _deviceId.deviceId,
        'syncedAt': FieldValue.serverTimestamp(),
      };

  Future<Map<String, dynamic>?> _buildDocument(SyncQueueItem item) async {
    switch (item.entityType) {
      case 'products':
        return _productDoc(await _isar.isar.productIsars.filter().idEqualTo(item.entityId).findFirst());
      case 'categories':
        return _categoryDoc(await _isar.isar.categoryIsars.filter().idEqualTo(item.entityId).findFirst());
      case 'customers':
        return _customerDoc(await _isar.isar.customerIsars.filter().idEqualTo(item.entityId).findFirst());
      case 'suppliers':
        return _supplierDoc(await _isar.isar.supplierIsars.filter().idEqualTo(item.entityId).findFirst());
      case 'sales':
        return _saleDoc(await _isar.isar.saleIsars.filter().idEqualTo(item.entityId).findFirst());
      case 'purchases':
        return _purchaseDoc(await _isar.isar.purchaseIsars.filter().idEqualTo(item.entityId).findFirst());
      case 'stockMovements':
        return _stockDoc(await _isar.isar.stockMovementIsars.filter().idEqualTo(item.entityId).findFirst());
      case 'khataTransactions':
        return _khataDoc(await _isar.isar.khataTransactionIsars.filter().idEqualTo(item.entityId).findFirst());
      case 'expenses':
        return _expenseDoc(await _isar.isar.expenseIsars.filter().idEqualTo(item.entityId).findFirst());
      case 'payments':
        return _paymentDoc(await _isar.isar.paymentIsars.filter().idEqualTo(item.entityId).findFirst());
      case 'auditLogs':
        return _auditDoc(await _isar.isar.auditLogIsars.filter().idEqualTo(item.entityId).findFirst());
      default:
        return null;
    }
  }

  Map<String, dynamic>? _productDoc(ProductIsar? p) {
    if (p == null) return null;
    return {
      'id': p.id,
      'storeId': p.storeId,
      'name': p.name,
      'barcode': p.barcode,
      'sku': p.sku,
      'categoryId': p.categoryId,
      'unitType': p.unitType,
      'baseUnit': p.baseUnit,
      'purchasePrice': p.purchasePrice,
      'sellingPrice': p.sellingPrice,
      'taxRate': p.taxRate,
      'minimumStock': p.minimumStock,
      'isActive': p.isActive,
      'createdAt': Timestamp.fromDate(p.createdAt),
      'updatedAt': Timestamp.fromDate(p.updatedAt),
      ..._syncMeta(p.storeId),
    };
  }

  Map<String, dynamic>? _categoryDoc(CategoryIsar? c) {
    if (c == null) return null;
    return {
      'id': c.id,
      'storeId': c.storeId,
      'name': c.name,
      'isActive': c.isActive,
      'createdAt': Timestamp.fromDate(c.createdAt),
      'updatedAt': Timestamp.fromDate(c.updatedAt),
      ..._syncMeta(c.storeId),
    };
  }

  Map<String, dynamic>? _customerDoc(CustomerIsar? c) {
    if (c == null) return null;
    return {
      'id': c.id,
      'storeId': c.storeId,
      'name': c.name,
      'phone': c.phone,
      'email': c.email,
      'address': c.address,
      'openingBalance': c.openingBalance,
      'creditLimit': c.creditLimit,
      'isActive': c.isActive,
      'createdAt': Timestamp.fromDate(c.createdAt),
      'updatedAt': Timestamp.fromDate(c.updatedAt),
      ..._syncMeta(c.storeId),
    };
  }

  Map<String, dynamic>? _supplierDoc(SupplierIsar? s) {
    if (s == null) return null;
    return {
      'id': s.id,
      'storeId': s.storeId,
      'name': s.name,
      'phone': s.phone,
      'email': s.email,
      'address': s.address,
      'openingBalance': s.openingBalance,
      'createdAt': Timestamp.fromDate(s.createdAt),
      'updatedAt': Timestamp.fromDate(s.updatedAt),
      ..._syncMeta(s.storeId),
    };
  }

  Future<Map<String, dynamic>?> _saleDoc(SaleIsar? sale) async {
    if (sale == null) return null;
    final items = await _isar.isar.saleItemIsars.filter().saleIdEqualTo(sale.id).findAll();
    return {
      'id': sale.id,
      'storeId': sale.storeId,
      'invoiceNumber': sale.invoiceNumber,
      'saleDate': Timestamp.fromDate(sale.saleDate),
      'customerId': sale.customerId,
      'paymentStatus': sale.paymentStatus,
      'paymentMethodSummary': sale.paymentMethodSummary,
      'subtotal': sale.subtotal,
      'discount': sale.discount,
      'tax': sale.tax,
      'total': sale.total,
      'paidAmount': sale.paidAmount,
      'dueAmount': sale.dueAmount,
      'createdBy': sale.createdBy,
      'createdAt': Timestamp.fromDate(sale.createdAt),
      'updatedAt': Timestamp.fromDate(sale.updatedAt),
      'items': items
          .map(
            (i) => {
              'id': i.id,
              'productId': i.productId,
              'productName': i.productName,
              'quantity': i.quantity,
              'unit': i.unit,
              'rate': i.rate,
              'discount': i.discount,
              'tax': i.tax,
              'amount': i.amount,
              'costPrice': i.costPrice,
            },
          )
          .toList(),
      ..._syncMeta(sale.storeId),
    };
  }

  Future<Map<String, dynamic>?> _purchaseDoc(PurchaseIsar? purchase) async {
    if (purchase == null) return null;
    final items = await _isar.isar.purchaseItemIsars.filter().purchaseIdEqualTo(purchase.id).findAll();
    return {
      'id': purchase.id,
      'storeId': purchase.storeId,
      'supplierId': purchase.supplierId,
      'invoiceNumber': purchase.invoiceNumber,
      'purchaseDate': Timestamp.fromDate(purchase.purchaseDate),
      'subtotal': purchase.subtotal,
      'discount': purchase.discount,
      'tax': purchase.tax,
      'total': purchase.total,
      'paidAmount': purchase.paidAmount,
      'dueAmount': purchase.dueAmount,
      'paymentStatus': purchase.paymentStatus,
      'createdBy': purchase.createdBy,
      'createdAt': Timestamp.fromDate(purchase.createdAt),
      'updatedAt': Timestamp.fromDate(purchase.updatedAt),
      'items': items
          .map(
            (i) => {
              'id': i.id,
              'productId': i.productId,
              'quantity': i.quantity,
              'unit': i.unit,
              'rate': i.rate,
              'amount': i.amount,
            },
          )
          .toList(),
      ..._syncMeta(purchase.storeId),
    };
  }

  Map<String, dynamic>? _stockDoc(StockMovementIsar? m) {
    if (m == null) return null;
    return {
      'id': m.id,
      'storeId': m.storeId,
      'productId': m.productId,
      'type': m.type,
      'quantity': m.quantity,
      'unit': m.unit,
      'referenceId': m.referenceId,
      'reason': m.reason,
      'createdBy': m.createdBy,
      'createdAt': Timestamp.fromDate(m.createdAt),
      ..._syncMeta(m.storeId),
    };
  }

  Map<String, dynamic>? _khataDoc(KhataTransactionIsar? t) {
    if (t == null) return null;
    return {
      'id': t.id,
      'storeId': t.storeId,
      'customerId': t.customerId,
      'type': t.type,
      'amount': t.amount,
      'referenceId': t.referenceId,
      'description': t.description,
      'balanceAfter': t.balanceAfter,
      'createdBy': t.createdBy,
      'createdAt': Timestamp.fromDate(t.createdAt),
      ..._syncMeta(t.storeId),
    };
  }

  Map<String, dynamic>? _expenseDoc(ExpenseIsar? e) {
    if (e == null) return null;
    return {
      'id': e.id,
      'storeId': e.storeId,
      'category': e.category,
      'amount': e.amount,
      'paymentMethod': e.paymentMethod,
      'description': e.description,
      'date': Timestamp.fromDate(e.date),
      'createdBy': e.createdBy,
      'createdAt': Timestamp.fromDate(e.createdAt),
      'updatedAt': Timestamp.fromDate(e.updatedAt),
      ..._syncMeta(e.storeId),
    };
  }

  Map<String, dynamic>? _auditDoc(AuditLogIsar? a) {
    if (a == null) return null;
    return {
      'id': a.id,
      'storeId': a.storeId,
      'userId': a.userId,
      'userDisplayName': a.userDisplayName,
      'action': a.action,
      'entityType': a.entityType,
      'entityId': a.entityId,
      'oldValueJson': a.oldValueJson,
      'newValueJson': a.newValueJson,
      'deviceId': a.deviceId,
      'createdAt': Timestamp.fromDate(a.createdAt),
      ..._syncMeta(a.storeId),
    };
  }

  Map<String, dynamic>? _paymentDoc(PaymentIsar? p) {
    if (p == null) return null;
    return {
      'id': p.id,
      'storeId': p.storeId,
      'partyType': p.partyType,
      'partyId': p.partyId,
      'amount': p.amount,
      'paymentMethod': p.paymentMethod,
      'referenceId': p.referenceId,
      'description': p.description,
      'paymentDate': Timestamp.fromDate(p.paymentDate),
      'createdBy': p.createdBy,
      'createdAt': Timestamp.fromDate(p.createdAt),
      ..._syncMeta(p.storeId),
    };
  }

  Future<void> _markEntitySynced(String entityType, String entityId) async {
    final now = DateTime.now();
    final device = _deviceId.deviceId;
    await _isar.isar.writeTxn(() async {
      Future<void> mark<T>(Future<T?> Function() load, Future<int> Function(T) save) async {
        final row = await load();
        if (row == null) return;
        (row as dynamic).sync.syncStatus = SyncStatus.synced.name;
        (row as dynamic).sync.deviceId = device;
        (row as dynamic).sync.lastSyncedAt = now;
        await save(row);
      }

      switch (entityType) {
        case 'products':
          await mark(
            () => _isar.isar.productIsars.filter().idEqualTo(entityId).findFirst(),
            _isar.isar.productIsars.put,
          );
        case 'categories':
          await mark(
            () => _isar.isar.categoryIsars.filter().idEqualTo(entityId).findFirst(),
            _isar.isar.categoryIsars.put,
          );
        case 'customers':
          await mark(
            () => _isar.isar.customerIsars.filter().idEqualTo(entityId).findFirst(),
            _isar.isar.customerIsars.put,
          );
        case 'suppliers':
          await mark(
            () => _isar.isar.supplierIsars.filter().idEqualTo(entityId).findFirst(),
            _isar.isar.supplierIsars.put,
          );
        case 'sales':
          await mark(
            () => _isar.isar.saleIsars.filter().idEqualTo(entityId).findFirst(),
            _isar.isar.saleIsars.put,
          );
        case 'purchases':
          await mark(
            () => _isar.isar.purchaseIsars.filter().idEqualTo(entityId).findFirst(),
            _isar.isar.purchaseIsars.put,
          );
        case 'stockMovements':
          await mark(
            () => _isar.isar.stockMovementIsars.filter().idEqualTo(entityId).findFirst(),
            _isar.isar.stockMovementIsars.put,
          );
        case 'khataTransactions':
          await mark(
            () => _isar.isar.khataTransactionIsars.filter().idEqualTo(entityId).findFirst(),
            _isar.isar.khataTransactionIsars.put,
          );
        case 'expenses':
          await mark(
            () => _isar.isar.expenseIsars.filter().idEqualTo(entityId).findFirst(),
            _isar.isar.expenseIsars.put,
          );
        case 'payments':
          await mark(
            () => _isar.isar.paymentIsars.filter().idEqualTo(entityId).findFirst(),
            _isar.isar.paymentIsars.put,
          );
        case 'auditLogs':
          await mark(
            () => _isar.isar.auditLogIsars.filter().idEqualTo(entityId).findFirst(),
            _isar.isar.auditLogIsars.put,
          );
      }
    });
  }
}
