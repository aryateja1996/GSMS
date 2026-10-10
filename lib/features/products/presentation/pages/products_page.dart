import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/constants/app_constants.dart';
import 'package:gsma/features/products/presentation/controllers/products_controller.dart';
import 'package:gsma/routes/app_routes.dart';

class ProductsPage extends GetView<ProductsController> {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Get.toNamed(AppRoutes.categories),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.productForm),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search name, SKU, barcode…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: controller.setSearch,
            ),
          ),
          Obx(() {
            if (controller.categories.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: controller.selectedCategoryId.value == null,
                      onSelected: (_) => controller.setCategoryFilter(null),
                    ),
                  ),
                  for (final c in controller.categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(c.name),
                        selected: controller.selectedCategoryId.value == c.id,
                        onSelected: (_) => controller.setCategoryFilter(c.id),
                      ),
                    ),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.products.isEmpty) {
                return const Center(child: Text('No products yet'));
              }
              return ListView.separated(
                itemCount: controller.products.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = controller.products[index];
                  return ListTile(
                    title: Text(p.name),
                    subtitle: Text(
                      '${AppConstants.defaultCurrencySymbol}${p.sellingPrice.toStringAsFixed(2)} · ${p.baseUnit}'
                      '${p.barcode != null ? ' · ${p.barcode}' : ''}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => Get.toNamed(
                        AppRoutes.productForm,
                        parameters: {'id': p.id},
                      ),
                    ),
                    onLongPress: () => controller.deactivate(p.id),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
