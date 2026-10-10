import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/sync/sync_status.dart';
import 'package:gsma/features/sync/presentation/controllers/sync_queue_controller.dart';

class SyncQueuePage extends GetView<SyncQueueController> {
  const SyncQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync queue'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: controller.load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.syncNow,
        icon: const Icon(Icons.sync),
        label: const Text('Sync now'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.items.isEmpty) {
          return const Center(child: Text('Queue is empty'));
        }
        final hasFailed = controller.items.any((i) => i.syncStatus == SyncStatus.failed.name);
        return Column(
          children: [
            if (hasFailed)
              Padding(
                padding: const EdgeInsets.all(12),
                child: OutlinedButton(
                  onPressed: controller.retryFailed,
                  child: const Text('Retry all failed'),
                ),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: controller.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final item = controller.items[i];
                  return ListTile(
                    title: Text('${item.entityType} · ${item.action}'),
                    subtitle: Text(
                      item.lastError ?? item.entityId,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(item.syncStatus),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
