import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/constants/app_constants.dart';
import 'package:gsma/core/constants/payment_methods.dart';
import 'package:gsma/features/pos/presentation/controllers/pos_controller.dart';

class PosPage extends GetView<PosController> {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS'),
        actions: [
          Obx(() {
            if (controller.lastInvoice.value.isEmpty) return const SizedBox.shrink();
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text('Last: ${controller.lastInvoice.value}'),
              ),
            );
          }),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 800;
          if (wide) {
            return Row(
              children: [
                Expanded(flex: 5, child: _SearchPanel(controller: controller)),
                const VerticalDivider(width: 1),
                Expanded(flex: 4, child: _CartPanel(controller: controller)),
              ],
            );
          }
          return Column(
            children: [
              Expanded(flex: 4, child: _SearchPanel(controller: controller)),
              const Divider(height: 1),
              Expanded(flex: 5, child: _CartPanel(controller: controller)),
            ],
          );
        },
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({required this.controller});

  final PosController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search or scan barcode…',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: controller.onSearchChanged,
                  onSubmitted: controller.addByBarcode,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.searchResults.isEmpty) {
              return const Center(child: Text('Search products to add'));
            }
            return ListView.builder(
              itemCount: controller.searchResults.length,
              itemBuilder: (context, i) {
                final p = controller.searchResults[i];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text(
                    '${AppConstants.defaultCurrencySymbol}${p.sellingPrice.toStringAsFixed(2)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => controller.addProduct(p),
                  ),
                  onTap: () => controller.addProduct(p),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _CartPanel extends StatelessWidget {
  const _CartPanel({required this.controller});

  final PosController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Text('Cart', style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: Obx(() {
            if (controller.cart.isEmpty) {
              return const Center(child: Text('Cart is empty'));
            }
            return ListView.builder(
              itemCount: controller.cart.length,
              itemBuilder: (context, index) {
                final line = controller.cart[index];
                return ListTile(
                  title: Text(line.product.name),
                  subtitle: Text(
                    '${AppConstants.defaultCurrencySymbol}${line.rate.toStringAsFixed(2)} × ${line.quantity}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () =>
                            controller.updateQuantity(index, line.quantity - 1),
                      ),
                      Text('${line.quantity}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () =>
                            controller.updateQuantity(index, line.quantity + 1),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
        Obx(() {
          final t = controller.totals;
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Subtotal: ${AppConstants.defaultCurrencySymbol}${t.subtotal.toStringAsFixed(2)}'),
                Text('Tax: ${AppConstants.defaultCurrencySymbol}${t.tax.toStringAsFixed(2)}'),
                Text(
                  'Total: ${AppConstants.defaultCurrencySymbol}${t.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final isCredit =
                      controller.paymentMethod.value == PaymentMethod.credit;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<PaymentMethod>(
                        initialValue: controller.paymentMethod.value,
                        decoration: const InputDecoration(labelText: 'Payment'),
                        items: PaymentMethod.values
                            .where((p) => p != PaymentMethod.split)
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.label),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) controller.paymentMethod.value = v;
                        },
                      ),
                      if (isCredit) ...[
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: controller.selectedCustomer.value?.id,
                          decoration: const InputDecoration(labelText: 'Customer *'),
                          items: controller.customers
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (id) {
                            controller.selectedCustomer.value =
                                controller.customers.firstWhere((c) => c.id == id);
                          },
                        ),
                      ],
                    ],
                  );
                }),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.clearCart,
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Obx(() {
                        return FilledButton(
                          onPressed: controller.isProcessing.value
                              ? null
                              : controller.checkout,
                          child: controller.isProcessing.value
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Complete sale'),
                        );
                      }),
                    ),
                  ],
                ),
                if (controller.errorMessage.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
