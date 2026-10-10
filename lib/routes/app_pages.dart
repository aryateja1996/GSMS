import 'package:get/get.dart';
import 'package:gsma/features/auth/presentation/bindings/auth_binding.dart';
import 'package:gsma/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:gsma/features/auth/presentation/pages/join_store_page.dart';
import 'package:gsma/features/auth/presentation/pages/login_page.dart';
import 'package:gsma/features/auth/presentation/pages/store_setup_page.dart';
import 'package:gsma/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:gsma/features/inventory/presentation/pages/inventory_page.dart';
import 'package:gsma/features/khata/presentation/pages/khata_page.dart';
import 'package:gsma/features/more/presentation/pages/more_page.dart';
import 'package:gsma/features/pos/presentation/pages/pos_page.dart';
import 'package:gsma/core/di/business_binding.dart';
import 'package:gsma/features/products/presentation/pages/categories_page.dart';
import 'package:gsma/features/products/presentation/pages/product_form_page.dart';
import 'package:gsma/features/products/presentation/pages/products_page.dart';
import 'package:gsma/features/products/presentation/controllers/product_form_controller.dart';
import 'package:gsma/features/products/presentation/controllers/products_controller.dart';
import 'package:gsma/features/cash/presentation/pages/cash_reconciliation_page.dart';
import 'package:gsma/features/customers/presentation/pages/customer_form_page.dart';
import 'package:gsma/features/expenses/presentation/pages/expense_form_page.dart';
import 'package:gsma/features/expenses/presentation/pages/expenses_page.dart';
import 'package:gsma/features/customers/presentation/pages/customers_page.dart';
import 'package:gsma/features/khata/presentation/pages/khata_statement_page.dart';
import 'package:gsma/features/purchases/presentation/pages/purchase_form_page.dart';
import 'package:gsma/features/purchases/presentation/pages/purchases_page.dart';
import 'package:gsma/features/suppliers/presentation/pages/suppliers_page.dart';
import 'package:gsma/features/audit/presentation/pages/audit_log_page.dart';
import 'package:gsma/features/notifications/presentation/pages/notifications_page.dart';
import 'package:gsma/features/settings/presentation/pages/settings_page.dart';
import 'package:gsma/features/sync/presentation/pages/sync_queue_page.dart';
import 'package:gsma/features/users/presentation/pages/add_staff_page.dart';
import 'package:gsma/features/users/presentation/pages/users_page.dart';
import 'package:gsma/features/reports/presentation/pages/reports_page.dart';
import 'package:gsma/features/shell/presentation/controllers/main_shell_controller.dart';
import 'package:gsma/features/shell/presentation/pages/main_shell_page.dart';
import 'package:gsma/features/splash/presentation/pages/splash_page.dart';
import 'package:gsma/routes/app_routes.dart';
import 'package:gsma/routes/auth_middleware.dart';

abstract final class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.storeSetup,
      page: () => const StoreSetupPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.joinStore,
      page: () => const JoinStorePage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.mainShell,
      page: () => const MainShellPage(),
      binding: BindingsBuilder(() {
        AuthBinding().dependencies();
        BusinessBinding().dependencies();
        Get.lazyPut(MainShellController.new);
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: AppRoutes.dashboard, page: () => const DashboardPage()),
    GetPage(name: AppRoutes.pos, page: () => const PosPage()),
    GetPage(name: AppRoutes.inventory, page: () => const InventoryPage()),
    GetPage(name: AppRoutes.purchases, page: () => const PurchasesPage()),
    GetPage(name: AppRoutes.khata, page: () => const KhataPage()),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsPage(),
      binding: BindingsBuilder(BusinessBinding().dependencies),
    ),
    GetPage(name: AppRoutes.more, page: () => const MorePage()),
    GetPage(
      name: AppRoutes.products,
      page: () => const ProductsPage(),
      binding: BindingsBuilder(() {
        BusinessBinding().dependencies();
        Get.find<ProductsController>();
      }),
    ),
    GetPage(
      name: AppRoutes.productForm,
      page: () => const ProductFormPage(),
      binding: BindingsBuilder(() {
        BusinessBinding().dependencies();
        Get.lazyPut(
          () => ProductFormController(Get.find(), Get.find()),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.categories,
      page: () => const CategoriesPage(),
      binding: BindingsBuilder(BusinessBinding().dependencies),
    ),
    GetPage(
      name: AppRoutes.customers,
      page: () => const CustomersPage(),
      binding: BindingsBuilder(BusinessBinding().dependencies),
    ),
    GetPage(
      name: AppRoutes.customerForm,
      page: () => const CustomerFormPage(),
      binding: BindingsBuilder(BusinessBinding().dependencies),
    ),
    GetPage(
      name: AppRoutes.khataStatement,
      page: () => const KhataStatementPage(),
      binding: BindingsBuilder(BusinessBinding().dependencies),
    ),
    GetPage(
      name: AppRoutes.suppliers,
      page: () => const SuppliersPage(),
      binding: BindingsBuilder(BusinessBinding().dependencies),
    ),
    GetPage(
      name: AppRoutes.purchaseForm,
      page: () => const PurchaseFormPage(),
      binding: BindingsBuilder(BusinessBinding().dependencies),
    ),
    GetPage(
      name: AppRoutes.expenses,
      page: () => const ExpensesPage(),
      binding: BindingsBuilder(BusinessBinding().dependencies),
    ),
    GetPage(
      name: AppRoutes.expenseForm,
      page: () => const ExpenseFormPage(),
      binding: BindingsBuilder(BusinessBinding().dependencies),
    ),
    GetPage(
      name: AppRoutes.cashReconciliation,
      page: () => const CashReconciliationPage(),
      binding: BindingsBuilder(BusinessBinding().dependencies),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsPage(),
      binding: BindingsBuilder(BusinessBinding().dependencies),
    ),
    GetPage(
      name: AppRoutes.users,
      page: () => const UsersPage(),
      binding: BindingsBuilder(BusinessBinding().dependencies),
    ),
    GetPage(
      name: AppRoutes.addStaff,
      page: () => const AddStaffPage(),
      binding: BindingsBuilder(BusinessBinding().dependencies),
    ),
    GetPage(
      name: AppRoutes.auditLog,
      page: () => const AuditLogPage(),
      binding: BindingsBuilder(BusinessBinding().dependencies),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      binding: BindingsBuilder(BusinessBinding().dependencies),
    ),
    GetPage(
      name: AppRoutes.syncQueue,
      page: () => const SyncQueuePage(),
      binding: BindingsBuilder(BusinessBinding().dependencies),
    ),
  ];
}
