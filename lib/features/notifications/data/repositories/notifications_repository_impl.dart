import 'package:get/get.dart';
import 'package:gsma/core/constants/app_constants.dart';
import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/core/sync/sync_manager.dart';
import 'package:gsma/features/khata/domain/repositories/khata_repository.dart';
import 'package:gsma/features/notifications/domain/entities/app_alert.dart';
import 'package:gsma/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:gsma/features/purchases/domain/repositories/purchase_repository.dart';
import 'package:gsma/features/reports/domain/repositories/reports_repository.dart';
import 'package:gsma/routes/app_routes.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(
    this._reports,
    this._khata,
    this._purchases,
    this._store,
  );

  final ReportsRepository _reports;
  final KhataRepository _khata;
  final PurchaseRepository _purchases;
  final StoreContext _store;

  @override
  Future<List<AppAlert>> loadAlerts() async {
    if (!_store.hasStore) return [];

    final alerts = <AppAlert>[];

    if (Get.isRegistered<SyncManager>()) {
      final sync = Get.find<SyncManager>();
      if (sync.failedCount.value > 0) {
        alerts.add(
          AppAlert(
            id: 'sync_failed',
            title: 'Sync failures',
            message:
                '${sync.failedCount.value} item(s) failed to upload. Open Sync queue to retry.',
            severity: AppAlertSeverity.critical,
            route: AppRoutes.syncQueue,
          ),
        );
      }
      if (sync.pendingCount.value > 0) {
        alerts.add(
          AppAlert(
            id: 'sync_pending',
            title: 'Pending sync',
            message: '${sync.pendingCount.value} change(s) waiting for cloud upload.',
            severity: AppAlertSeverity.info,
            route: AppRoutes.syncQueue,
          ),
        );
      }
    }

    final inventory = await _reports.inventoryReport();
    if (inventory.outOfStockCount > 0) {
      alerts.add(
        AppAlert(
          id: 'out_of_stock',
          title: 'Out of stock',
          message: '${inventory.outOfStockCount} active product(s) have zero stock.',
          severity: AppAlertSeverity.critical,
          route: AppRoutes.inventory,
        ),
      );
    }
    if (inventory.lowStockCount > 0) {
      alerts.add(
        AppAlert(
          id: 'low_stock',
          title: 'Low stock',
          message: '${inventory.lowStockCount} product(s) at or below minimum stock.',
          severity: AppAlertSeverity.warning,
          route: AppRoutes.inventory,
        ),
      );
    }

    final khataSummaries = await _khata.listCustomerSummaries();
    final withDue = khataSummaries.where((s) => s.outstanding > 0).toList();
    if (withDue.isNotEmpty) {
      final top = withDue.first;
      alerts.add(
        AppAlert(
          id: 'khata_due',
          title: 'Khata outstanding',
          message:
              '${withDue.length} customer(s) owe ${AppConstants.defaultCurrencySymbol}${withDue.fold<double>(0, (s, e) => s + e.outstanding).toStringAsFixed(0)} total. Highest: ${top.customerName}.',
          severity: AppAlertSeverity.warning,
          route: AppRoutes.khata,
        ),
      );
    }

    final purchases = await _purchases.listPurchases(limit: 30);
    final duePurchases = purchases.where((p) => p.dueAmount > 0).toList();
    if (duePurchases.isNotEmpty) {
      final dueTotal = duePurchases.fold(0.0, (s, p) => s + p.dueAmount);
      alerts.add(
        AppAlert(
          id: 'supplier_due',
          title: 'Supplier payments due',
          message:
              '${duePurchases.length} purchase(s) with ${AppConstants.defaultCurrencySymbol}${dueTotal.toStringAsFixed(0)} due.',
          severity: AppAlertSeverity.warning,
          route: AppRoutes.purchases,
        ),
      );
    }

    return alerts;
  }
}
