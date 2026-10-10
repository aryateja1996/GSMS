import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/constants/app_constants.dart';
import 'package:gsma/features/customers/presentation/controllers/customers_controller.dart';
import 'package:gsma/routes/app_routes.dart';

class CustomersPage extends GetView<CustomersController> {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.customerForm),
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search name or phone',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: controller.search,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.items.isEmpty) {
                return const Center(child: Text('No customers yet'));
              }
              return ListView.separated(
                itemCount: controller.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final row = controller.items[i];
                  return ListTile(
                    title: Text(row.customer.name),
                    subtitle: Text(row.customer.phone ?? ''),
                    trailing: Text(
                      '${AppConstants.defaultCurrencySymbol}${row.outstanding.toStringAsFixed(0)}',
                    ),
                    onTap: () => Get.toNamed(
                      AppRoutes.khataStatement,
                      parameters: {'customerId': row.customer.id},
                    ),
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
