import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/features/inventory/presentation/controllers/inventory_controller.dart';

class InventoryPage extends GetView<InventoryController> {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: controller.load),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search products…',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (v) {
                    controller.searchQuery.value = v;
                    controller.load();
                  },
                ),
              ),
              const TabBar(tabs: [Tab(text: 'Stock'), Tab(text: 'Movements')]),
              Expanded(
                child: TabBarView(
                  children: [
                    _StockTab(controller: controller),
                    _MovementsTab(controller: controller),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StockTab extends StatelessWidget {
  const _StockTab({required this.controller});

  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.stockList.isEmpty) {
        return const Center(child: Text('No products — add products first'));
      }
      return ListView.separated(
        itemCount: controller.stockList.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final s = controller.stockList[index];
          final trailing = s.isOutOfStock
              ? 'Out'
              : s.isLowStock
                  ? 'Low'
                  : 'OK';
          return ListTile(
            title: Text(s.productName),
            subtitle: Text('${s.quantity} ${s.unit}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(trailing),
                IconButton(
                  icon: const Icon(Icons.add_box_outlined),
                  onPressed: () => _stockInDialog(context, s.productId, s.productName),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Future<void> _stockInDialog(
    BuildContext context,
    String productId,
    String name,
  ) async {
    final qty = TextEditingController(text: '1');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Stock in — $name'),
        content: TextField(
          controller: qty,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantity'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await controller.stockIn(
        productId: productId,
        quantity: double.tryParse(qty.text) ?? 0,
      );
    }
  }
}

class _MovementsTab extends StatelessWidget {
  const _MovementsTab({required this.controller});

  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.recentMovements.isEmpty) {
        return const Center(child: Text('No stock movements yet'));
      }
      return ListView.builder(
        itemCount: controller.recentMovements.length,
        itemBuilder: (context, i) {
          final m = controller.recentMovements[i];
          return ListTile(
            title: Text('${m.type.name} · ${m.quantity} ${m.unit}'),
            subtitle: Text(m.reason ?? m.referenceId ?? ''),
          );
        },
      );
    });
  }
}
