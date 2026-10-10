import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/constants/app_constants.dart';
import 'package:gsma/features/purchases/presentation/controllers/purchases_controller.dart';
import 'package:gsma/routes/app_routes.dart';

class PurchasesPage extends GetView<PurchasesController> {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchases'),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_shipping_outlined),
            onPressed: () => Get.toNamed(AppRoutes.suppliers),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.purchaseForm)?.then((_) => controller.load()),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.items.isEmpty) {
          return const Center(child: Text('No purchases yet'));
        }
        return ListView.separated(
          itemCount: controller.items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final p = controller.items[i];
            return ListTile(
              title: Text('${p.supplierName} · ${p.invoiceNumber}'),
              subtitle: Text(
                '${AppConstants.defaultCurrencySymbol}${p.total.toStringAsFixed(2)} · ${p.paymentStatus}',
              ),
              trailing: p.dueAmount > 0
                  ? TextButton(
                      onPressed: () => _pay(context, p.id, p.dueAmount),
                      child: Text('Pay ${p.dueAmount.toStringAsFixed(0)}'),
                    )
                  : null,
            );
          },
        );
      }),
    );
  }

  Future<void> _pay(BuildContext context, String purchaseId, double due) async {
    final amount = TextEditingController(text: due.toStringAsFixed(2));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supplier payment'),
        content: TextField(
          controller: amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Pay')),
        ],
      ),
    );
    if (ok == true) {
      await controller.payDue(purchaseId, double.tryParse(amount.text) ?? 0);
    }
  }
}
