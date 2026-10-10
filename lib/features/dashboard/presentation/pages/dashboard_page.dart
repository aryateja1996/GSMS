import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/constants/app_constants.dart';
import 'package:gsma/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:gsma/features/shell/presentation/controllers/main_shell_controller.dart';
import 'package:gsma/routes/app_routes.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sym = AppConstants.defaultCurrencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshMetrics,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Business overview', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Live metrics from sales, inventory, Khata, and expenses.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  title: "Today's sales",
                  value: '$sym${controller.todaySales.value.toStringAsFixed(0)}',
                ),
                _MetricCard(
                  title: "Today's profit",
                  value: '$sym${controller.todayProfit.value.toStringAsFixed(0)}',
                ),
                _MetricCard(
                  title: 'Low / out of stock',
                  value: '${controller.lowStock.value}',
                ),
                _MetricCard(
                  title: 'Khata outstanding',
                  value: '$sym${controller.khataOutstanding.value.toStringAsFixed(0)}',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Quick actions', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickActionChip(
                  label: 'New Sale',
                  icon: Icons.point_of_sale,
                  onTap: () {
                    if (Get.isRegistered<MainShellController>()) {
                      Get.find<MainShellController>().selectTab(1);
                    }
                  },
                ),
                _QuickActionChip(
                  label: 'Add Product',
                  icon: Icons.add_box_outlined,
                  onTap: () => Get.toNamed(AppRoutes.products),
                ),
                _QuickActionChip(
                  label: 'New Purchase',
                  icon: Icons.shopping_cart_outlined,
                  onTap: () => Get.toNamed(AppRoutes.purchaseForm),
                ),
                _QuickActionChip(
                  label: 'Add Customer',
                  icon: Icons.person_add_outlined,
                  onTap: () => Get.toNamed(AppRoutes.customerForm),
                ),
                _QuickActionChip(
                  label: 'Add Expense',
                  icon: Icons.receipt_long_outlined,
                  onTap: () => Get.toNamed(AppRoutes.expenseForm),
                ),
                _QuickActionChip(
                  label: 'View Reports',
                  icon: Icons.bar_chart,
                  onTap: () => Get.toNamed(AppRoutes.reports),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
