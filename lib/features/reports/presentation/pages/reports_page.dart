import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/constants/app_constants.dart';
import 'package:gsma/core/permissions/app_permissions.dart';
import 'package:gsma/core/permissions/permission_service.dart';
import 'package:gsma/features/reports/domain/repositories/reports_repository.dart';
import 'package:gsma/features/reports/presentation/controllers/reports_controller.dart';

class ReportsPage extends GetView<ReportsController> {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final canViewProfit = Get.find<PermissionService>().can(AppPermissions.canViewProfit);
    final sym = AppConstants.defaultCurrencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          PopupMenuButton<ReportPeriod>(
            onSelected: controller.setPeriod,
            itemBuilder: (_) => const [
              PopupMenuItem(value: ReportPeriod.today, child: Text('Today')),
              PopupMenuItem(value: ReportPeriod.week, child: Text('Last 7 days')),
              PopupMenuItem(value: ReportPeriod.month, child: Text('This month')),
              PopupMenuItem(value: ReportPeriod.year, child: Text('This year')),
            ],
            icon: const Icon(Icons.date_range),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final sales = controller.sales.value;
        final profit = controller.profit.value;
        final inventory = controller.inventory.value;

        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Sales', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (sales != null) ...[
                _metric(context, 'Transactions', '${sales.saleCount}'),
                _metric(context, 'Net sales', '$sym${sales.netTotal.toStringAsFixed(2)}'),
                _metric(context, 'Discounts', '$sym${sales.discounts.toStringAsFixed(2)}'),
                _metric(context, 'Tax collected', '$sym${sales.tax.toStringAsFixed(2)}'),
                if (sales.byPaymentMethod.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('By payment method', style: Theme.of(context).textTheme.titleSmall),
                  ...sales.byPaymentMethod.entries.map(
                    (e) => _metric(context, e.key, '$sym${e.value.toStringAsFixed(2)}'),
                  ),
                ],
              ],
              const Divider(height: 32),
              Text('Profit', style: Theme.of(context).textTheme.titleLarge),
              if (!canViewProfit)
                const ListTile(title: Text('Profit details require permission'))
              else if (profit != null) ...[
                _metric(context, 'Gross profit', '$sym${profit.grossProfit.toStringAsFixed(2)}'),
                _metric(context, 'Expenses', '$sym${profit.expenses.toStringAsFixed(2)}'),
                _metric(context, 'Net operating profit', '$sym${profit.netOperatingProfit.toStringAsFixed(2)}'),
                _metric(context, 'Margin', '${profit.profitMargin.toStringAsFixed(1)}%'),
              ],
              const Divider(height: 32),
              Text('Inventory', style: Theme.of(context).textTheme.titleLarge),
              if (inventory != null) ...[
                _metric(context, 'Stock value (cost)', '$sym${inventory.stockValue.toStringAsFixed(2)}'),
                _metric(context, 'Low stock SKUs', '${inventory.lowStockCount}'),
                _metric(context, 'Out of stock SKUs', '${inventory.outOfStockCount}'),
              ],
              const Divider(height: 32),
              Text('Purchases & Khata', style: Theme.of(context).textTheme.titleLarge),
              _metric(context, 'Purchase total', '$sym${controller.purchaseTotal.value.toStringAsFixed(2)}'),
              _metric(context, 'Khata outstanding', '$sym${controller.khataOutstanding.value.toStringAsFixed(2)}'),
              _metric(context, 'Khata collections', '$sym${controller.khataCollections.value.toStringAsFixed(2)}'),
              _metric(context, 'Credit sales', '$sym${controller.creditSales.value.toStringAsFixed(2)}'),
              const Divider(height: 32),
              Text('Expenses by category', style: Theme.of(context).textTheme.titleLarge),
              if (controller.expensesByCategory.isEmpty)
                const ListTile(title: Text('No expenses in period'))
              else
                ...controller.expensesByCategory.entries.map(
                  (e) => _metric(context, e.key, '$sym${e.value.toStringAsFixed(2)}'),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _metric(BuildContext context, String label, String value) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
