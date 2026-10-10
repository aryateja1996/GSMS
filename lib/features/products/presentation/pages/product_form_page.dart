import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/constants/unit_types.dart';
import 'package:gsma/features/products/presentation/controllers/product_form_controller.dart';

class ProductFormPage extends GetView<ProductFormController> {
  const ProductFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final name = TextEditingController(text: controller.editing.value?.name ?? '');
    final barcode = TextEditingController(text: controller.editing.value?.barcode ?? '');
    final sku = TextEditingController(text: controller.editing.value?.sku ?? '');
    final purchase = TextEditingController(
      text: '${controller.editing.value?.purchasePrice ?? 0}',
    );
    final selling = TextEditingController(
      text: '${controller.editing.value?.sellingPrice ?? 0}',
    );
    final mrp = TextEditingController(text: '${controller.editing.value?.mrp ?? 0}');
    final tax = TextEditingController(text: '${controller.editing.value?.taxRate ?? 0}');
    final minStock = TextEditingController(
      text: '${controller.editing.value?.minimumStock ?? 0}',
    );
    var categoryId = controller.editing.value?.categoryId ?? '';
    var unitType = controller.editing.value?.unitType ?? UnitType.piece;
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.editing.value == null ? 'Add product' : 'Edit product'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.editing.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Product name *'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: barcode,
                  decoration: const InputDecoration(labelText: 'Barcode'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: sku,
                  decoration: const InputDecoration(labelText: 'SKU'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: categoryId.isEmpty ? null : categoryId,
                  decoration: const InputDecoration(labelText: 'Category *'),
                  items: controller.categories
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => categoryId = v ?? categoryId,
                  validator: (v) => v == null || v.isEmpty ? 'Select category' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UnitType>(
                  value: unitType,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  items: UnitType.values
                      .map((u) => DropdownMenuItem(value: u, child: Text(u.label)))
                      .toList(),
                  onChanged: (v) => unitType = v ?? unitType,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: purchase,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Purchase price'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: selling,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Selling price *'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: mrp,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'MRP'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: tax,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Tax %'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: minStock,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Minimum stock'),
                ),
                const SizedBox(height: 24),
                Obx(() {
                  return FilledButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            final ok = await controller.save(
                              name: name.text,
                              barcode: barcode.text,
                              sku: sku.text,
                              categoryId: categoryId,
                              unitType: unitType,
                              purchasePrice: double.tryParse(purchase.text) ?? 0,
                              sellingPrice: double.tryParse(selling.text) ?? 0,
                              mrp: double.tryParse(mrp.text) ?? 0,
                              taxRate: double.tryParse(tax.text) ?? 0,
                              minimumStock: double.tryParse(minStock.text) ?? 0,
                            );
                            if (ok) Get.back(result: true);
                          },
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save product'),
                  );
                }),
                if (controller.errorMessage.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
