import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/constants/app_constants.dart';
import 'package:gsma/features/expenses/presentation/controllers/expenses_controller.dart';
import 'package:gsma/routes/app_routes.dart';

class ExpensesPage extends GetView<ExpensesController> {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: 'Cash reconciliation',
            onPressed: () => Get.toNamed(AppRoutes.cashReconciliation),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.expenseForm)?.then((_) => controller.load()),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.items.isEmpty) {
          return const Center(child: Text('No expenses this month'));
        }
        return ListView.separated(
          itemCount: controller.items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final e = controller.items[i];
            return ListTile(
              title: Text('${e.category} · ${AppConstants.defaultCurrencySymbol}${e.amount.toStringAsFixed(0)}'),
              subtitle: Text(
                '${e.date.toLocal().toString().split(' ').first} · ${e.paymentMethod}',
              ),
              trailing: Text(e.description ?? '', overflow: TextOverflow.ellipsis),
            );
          },
        );
      }),
    );
  }
}
