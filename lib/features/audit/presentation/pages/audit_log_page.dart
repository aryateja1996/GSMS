import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/features/audit/presentation/controllers/audit_log_controller.dart';

class AuditLogPage extends GetView<AuditLogController> {
  const AuditLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit log'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: controller.load),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.items.isEmpty) {
          return const Center(child: Text('No audit entries yet'));
        }
        return ListView.separated(
          itemCount: controller.items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final e = controller.items[i];
            return ListTile(
              title: Text('${e.action} · ${e.entityType}'),
              subtitle: Text(
                '${e.userDisplayName} · ${e.createdAt.toLocal()}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(e.entityId.length > 8 ? e.entityId.substring(0, 8) : e.entityId),
            );
          },
        );
      }),
    );
  }
}
