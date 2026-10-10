import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/network/connectivity_service.dart';
import 'package:gsma/core/sync/sync_manager.dart';

class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = Get.find<ConnectivityService>();
    final sync = Get.find<SyncManager>();

    return Obx(() {
      if (connectivity.isOnline.value && sync.pendingCount.value == 0) {
        return const SizedBox.shrink();
      }
      final offline = !connectivity.isOnline.value;
      final color = offline
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.tertiaryContainer;
      final failed = sync.failedCount.value;
      final text = offline
          ? 'Offline — changes saved locally'
          : sync.isSyncing.value
              ? 'Syncing ${sync.pendingCount.value} item(s)…'
              : failed > 0
                  ? '${sync.pendingCount.value} pending · $failed failed sync'
                  : '${sync.pendingCount.value} change(s) waiting to sync';

      return Material(
        color: color,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                offline ? Icons.cloud_off : Icons.sync,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
              if (!offline && !sync.isSyncing.value)
                TextButton(
                  onPressed: sync.triggerSync,
                  child: const Text('Sync now'),
                ),
            ],
          ),
        ),
      );
    });
  }
}
