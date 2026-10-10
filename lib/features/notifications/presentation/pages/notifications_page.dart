import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/features/notifications/domain/entities/app_alert.dart';
import 'package:gsma/features/notifications/presentation/controllers/notifications_controller.dart';

class NotificationsPage extends GetView<NotificationsController> {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: controller.load),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.alerts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.alerts.isEmpty) {
          return const Center(child: Text('No alerts right now'));
        }
        return ListView.separated(
          itemCount: controller.alerts.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final a = controller.alerts[i];
            return ListTile(
              leading: Icon(_icon(a.severity), color: _color(context, a.severity)),
              title: Text(a.title),
              subtitle: Text(a.message),
              onTap: a.route == null ? null : () => Get.toNamed(a.route!),
            );
          },
        );
      }),
    );
  }

  IconData _icon(AppAlertSeverity s) {
    switch (s) {
      case AppAlertSeverity.critical:
        return Icons.error_outline;
      case AppAlertSeverity.warning:
        return Icons.warning_amber_outlined;
      case AppAlertSeverity.info:
        return Icons.info_outline;
    }
  }

  Color _color(BuildContext context, AppAlertSeverity s) {
    final scheme = Theme.of(context).colorScheme;
    switch (s) {
      case AppAlertSeverity.critical:
        return scheme.error;
      case AppAlertSeverity.warning:
        return scheme.tertiary;
      case AppAlertSeverity.info:
        return scheme.primary;
    }
  }
}
