import 'package:gsma/core/database/collections/audit_log_isar.dart';
import 'package:gsma/core/database/collections/category_isar.dart';
import 'package:gsma/core/database/collections/customer_isar.dart';
import 'package:gsma/core/database/collections/expense_isar.dart';
import 'package:gsma/core/database/collections/khata_transaction_isar.dart';
import 'package:gsma/core/database/collections/local_app_setting.dart';
import 'package:gsma/core/database/collections/payment_isar.dart';
import 'package:gsma/core/database/collections/product_isar.dart';
import 'package:gsma/core/database/collections/purchase_isar.dart';
import 'package:gsma/core/database/collections/purchase_item_isar.dart';
import 'package:gsma/core/database/collections/sale_isar.dart';
import 'package:gsma/core/database/collections/sale_item_isar.dart';
import 'package:gsma/core/database/collections/stock_movement_isar.dart';
import 'package:gsma/core/database/collections/supplier_isar.dart';
import 'package:gsma/core/database/collections/sync_queue_item.dart';
import 'package:gsma/core/exceptions/app_exception.dart';
import 'package:gsma/core/utils/app_logger.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  Isar? _isar;

  Isar get isar {
    final instance = _isar;
    if (instance == null || !instance.isOpen) {
      throw AppException('Isar is not initialized');
    }
    return instance;
  }

  bool get isReady => _isar?.isOpen ?? false;

  /// [directory] overrides the DB path (used in tests); otherwise uses app documents.
  Future<void> init({String? directory}) async {
    if (_isar?.isOpen ?? false) return;

    final dirPath =
        directory ?? (await getApplicationDocumentsDirectory()).path;
    _isar = await Isar.open(
      [
        SyncQueueItemSchema,
        LocalAppSettingSchema,
        CategoryIsarSchema,
        ProductIsarSchema,
        CustomerIsarSchema,
        SupplierIsarSchema,
        SaleIsarSchema,
        SaleItemIsarSchema,
        PurchaseIsarSchema,
        PurchaseItemIsarSchema,
        StockMovementIsarSchema,
        KhataTransactionIsarSchema,
        ExpenseIsarSchema,
        PaymentIsarSchema,
        AuditLogIsarSchema,
      ],
      directory: dirPath,
      name: 'gsma',
    );
    AppLogger.info('Isar database opened', tag: 'IsarService');
  }

  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
