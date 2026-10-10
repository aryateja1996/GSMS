import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/constants/app_constants.dart';
import 'package:gsma/features/khata/presentation/controllers/khata_controller.dart';
import 'package:gsma/routes/app_routes.dart';

class KhataPage extends GetView<KhataController> {
  const KhataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khata'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () => Get.toNamed(AppRoutes.customers),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() => Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total outstanding', style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      '${AppConstants.defaultCurrencySymbol}${controller.totalOutstanding.value.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search customer',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (v) => controller.loadSummaries(query: v),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.summaries.isEmpty) {
                return const Center(child: Text('No Khata records'));
              }
              return ListView.separated(
                itemCount: controller.summaries.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final s = controller.summaries[i];
                  return ListTile(
                    title: Text(s.customerName),
                    subtitle: Text(s.phone ?? ''),
                    trailing: Text(
                      '${AppConstants.defaultCurrencySymbol}${s.outstanding.toStringAsFixed(0)}',
                    ),
                    onTap: () => Get.toNamed(
                      AppRoutes.khataStatement,
                      parameters: {'customerId': s.customerId},
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
