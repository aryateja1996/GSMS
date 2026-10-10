import 'package:get/get.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/core/sync/device_id_service.dart';
import 'package:gsma/core/sync/sync_enqueue_service.dart';
import 'package:gsma/core/sync/sync_manager.dart';
import 'package:gsma/features/customers/data/datasources/local/customer_local_datasource.dart';
import 'package:gsma/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:gsma/features/customers/domain/repositories/customer_repository.dart';
import 'package:gsma/features/customers/presentation/controllers/customers_controller.dart';
import 'package:gsma/features/inventory/data/datasources/local/stock_local_datasource.dart';
import 'package:gsma/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:gsma/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:gsma/features/inventory/presentation/controllers/inventory_controller.dart';
import 'package:gsma/features/khata/data/datasources/local/khata_local_datasource.dart';
import 'package:gsma/features/khata/data/repositories/khata_repository_impl.dart';
import 'package:gsma/features/khata/domain/repositories/khata_repository.dart';
import 'package:gsma/features/khata/presentation/controllers/khata_controller.dart';
import 'package:gsma/features/pos/data/datasources/local/sale_local_datasource.dart';
import 'package:gsma/features/pos/data/invoice_number_service.dart';
import 'package:gsma/features/pos/domain/usecases/complete_sale_usecase.dart';
import 'package:gsma/features/pos/presentation/controllers/pos_controller.dart';
import 'package:gsma/features/products/data/datasources/local/category_local_datasource.dart';
import 'package:gsma/features/products/data/datasources/local/product_local_datasource.dart';
import 'package:gsma/features/products/data/repositories/category_repository_impl.dart';
import 'package:gsma/features/products/data/repositories/product_repository_impl.dart';
import 'package:gsma/features/products/domain/repositories/category_repository.dart';
import 'package:gsma/features/products/domain/repositories/product_repository.dart';
import 'package:gsma/features/products/presentation/controllers/product_form_controller.dart';
import 'package:gsma/features/products/presentation/controllers/products_controller.dart';
import 'package:gsma/features/purchases/data/datasources/local/purchase_local_datasource.dart';
import 'package:gsma/features/purchases/data/repositories/purchase_repository_impl.dart';
import 'package:gsma/features/purchases/domain/repositories/purchase_repository.dart';
import 'package:gsma/features/purchases/presentation/controllers/purchases_controller.dart';
import 'package:gsma/features/suppliers/data/datasources/local/supplier_local_datasource.dart';
import 'package:gsma/features/suppliers/data/repositories/supplier_repository_impl.dart';
import 'package:gsma/features/suppliers/domain/repositories/supplier_repository.dart';
import 'package:gsma/core/audit/audit_log_service.dart';
import 'package:gsma/core/database/datasources/local/app_settings_local_datasource.dart';
import 'package:gsma/features/cash/data/repositories/cash_repository_impl.dart';
import 'package:gsma/features/cash/domain/repositories/cash_repository.dart';
import 'package:gsma/features/cash/presentation/controllers/cash_controller.dart';
import 'package:gsma/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:gsma/features/expenses/data/datasources/local/expense_local_datasource.dart';
import 'package:gsma/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:gsma/features/expenses/domain/repositories/expense_repository.dart';
import 'package:gsma/features/expenses/presentation/controllers/expenses_controller.dart';
import 'package:gsma/features/reports/data/datasources/local/reports_local_datasource.dart';
import 'package:gsma/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:gsma/features/reports/domain/repositories/reports_repository.dart';
import 'package:gsma/features/reports/presentation/controllers/reports_controller.dart';
import 'package:gsma/features/audit/data/datasources/local/audit_log_local_datasource.dart';
import 'package:gsma/features/audit/data/repositories/audit_log_repository_impl.dart';
import 'package:gsma/features/audit/domain/repositories/audit_log_repository.dart';
import 'package:gsma/features/audit/presentation/controllers/audit_log_controller.dart';
import 'package:gsma/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:gsma/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:gsma/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:gsma/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:gsma/features/settings/domain/repositories/settings_repository.dart';
import 'package:gsma/features/settings/presentation/controllers/settings_controller.dart';
import 'package:gsma/features/sync/presentation/controllers/sync_queue_controller.dart';
import 'package:gsma/features/users/data/datasources/remote/invite_remote_datasource.dart';
import 'package:gsma/features/users/data/datasources/remote/staff_remote_datasource.dart';
import 'package:gsma/features/users/data/repositories/staff_repository_impl.dart';
import 'package:gsma/features/users/domain/repositories/staff_repository.dart';
import 'package:gsma/features/users/presentation/controllers/users_controller.dart';

class BusinessBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StoreContext>()) {
      Get.put(StoreContext(), permanent: true);
    }

    final isar = Get.find<IsarService>();

    if (!Get.isRegistered<SyncEnqueueService>()) {
      Get.put(
        SyncEnqueueService(
          isar,
          Get.find<DeviceIdService>(),
          Get.find<SyncManager>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<AuditLogService>()) {
      Get.put(
        AuditLogService(
          isar,
          Get.find<StoreContext>(),
          Get.find<DeviceIdService>(),
          Get.find<SyncEnqueueService>(),
        ),
        permanent: true,
      );
    }

    Get.lazyPut(() => ProductLocalDataSource(isar), fenix: true);
    Get.lazyPut(() => CategoryLocalDataSource(isar), fenix: true);
    Get.lazyPut(() => StockLocalDataSource(isar), fenix: true);
    Get.lazyPut(() => SaleLocalDataSource(isar), fenix: true);
    Get.lazyPut(() => InvoiceNumberService(isar), fenix: true);
    Get.lazyPut(() => CustomerLocalDataSource(isar), fenix: true);
    Get.lazyPut(() => KhataLocalDataSource(isar), fenix: true);
    Get.lazyPut(() => SupplierLocalDataSource(isar), fenix: true);
    Get.lazyPut(() => PurchaseLocalDataSource(isar), fenix: true);
    Get.lazyPut(() => ExpenseLocalDataSource(isar), fenix: true);
    Get.lazyPut(() => AppSettingsLocalDataSource(isar), fenix: true);
    Get.lazyPut(() => AuditLogLocalDataSource(isar), fenix: true);
    Get.lazyPut(() => StaffRemoteDataSource(), fenix: true);
    if (!Get.isRegistered<InviteRemoteDataSource>()) {
      Get.put(InviteRemoteDataSource(), permanent: true);
    }
    Get.lazyPut(
      () => ReportsLocalDataSource(
        isar,
        Get.find<ExpenseLocalDataSource>(),
        Get.find<KhataLocalDataSource>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(
        Get.find(),
        Get.find<StoreContext>(),
        Get.find<SyncEnqueueService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CategoryRepository>(
      () => CategoryRepositoryImpl(
        Get.find(),
        Get.find<StoreContext>(),
        Get.find<SyncEnqueueService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<InventoryRepository>(
      () => InventoryRepositoryImpl(
        Get.find(),
        Get.find(),
        Get.find<StoreContext>(),
        Get.find<SyncEnqueueService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<KhataRepository>(
      () => KhataRepositoryImpl(
        Get.find(),
        Get.find(),
        Get.find<StoreContext>(),
        Get.find<SyncEnqueueService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CustomerRepository>(
      () => CustomerRepositoryImpl(
        Get.find(),
        Get.find<KhataRepository>(),
        Get.find<StoreContext>(),
        Get.find<SyncEnqueueService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<SupplierRepository>(
      () => SupplierRepositoryImpl(
        Get.find(),
        Get.find<StoreContext>(),
        Get.find<SyncEnqueueService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<PurchaseRepository>(
      () => PurchaseRepositoryImpl(
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find<StoreContext>(),
        Get.find<SyncEnqueueService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ExpenseRepository>(
      () => ExpenseRepositoryImpl(
        Get.find(),
        Get.find<StoreContext>(),
        Get.find<SyncEnqueueService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CashRepository>(
      () => CashRepositoryImpl(
        Get.find(),
        isar,
        Get.find(),
        Get.find(),
        Get.find<StoreContext>(),
        Get.find<SyncEnqueueService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ReportsRepository>(
      () => ReportsRepositoryImpl(
        Get.find(),
        Get.find(),
        Get.find<StoreContext>(),
      ),
      fenix: true,
    );
    Get.lazyPut<AuditLogRepository>(
      () => AuditLogRepositoryImpl(Get.find(), Get.find<StoreContext>()),
      fenix: true,
    );
    Get.lazyPut<NotificationsRepository>(
      () => NotificationsRepositoryImpl(
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find<StoreContext>(),
      ),
      fenix: true,
    );
    Get.lazyPut<SettingsRepository>(
      () => SettingsRepositoryImpl(Get.find(), Get.find<StoreContext>()),
      fenix: true,
    );
    Get.lazyPut<StaffRepository>(
      () => StaffRepositoryImpl(
        Get.find(),
        Get.find<InviteRemoteDataSource>(),
        Get.find<StoreContext>(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => CompleteSaleUseCase(
        store: Get.find<StoreContext>(),
        inventory: Get.find<InventoryRepository>(),
        saleLocal: Get.find<SaleLocalDataSource>(),
        invoiceNumbers: Get.find<InvoiceNumberService>(),
        syncEnqueue: Get.find<SyncEnqueueService>(),
        khata: Get.find<KhataRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut(() => ProductsController(Get.find(), Get.find()), fenix: true);
    Get.lazyPut(() => ProductFormController(Get.find(), Get.find()), fenix: true);
    Get.lazyPut(() => InventoryController(Get.find(), Get.find()), fenix: true);
    Get.lazyPut(
      () => PosController(Get.find(), Get.find(), Get.find()),
      fenix: true,
    );
    Get.lazyPut(() => KhataController(Get.find()), fenix: true);
    Get.lazyPut(() => CustomersController(Get.find(), Get.find()), fenix: true);
    Get.lazyPut(() => PurchasesController(Get.find()), fenix: true);
    Get.lazyPut(() => ExpensesController(Get.find()), fenix: true);
    Get.lazyPut(() => CashController(Get.find()), fenix: true);
    Get.lazyPut(() => ReportsController(Get.find()), fenix: true);
    Get.lazyPut(() => DashboardController(Get.find()), fenix: true);
    Get.lazyPut(() => AuditLogController(Get.find()), fenix: true);
    Get.lazyPut(() => NotificationsController(Get.find()), fenix: true);
    Get.lazyPut(() => SettingsController(Get.find()), fenix: true);
    Get.lazyPut(() => UsersController(Get.find()), fenix: true);
    Get.lazyPut(
      () => SyncQueueController(isar, Get.find<SyncManager>()),
      fenix: true,
    );
  }
}
