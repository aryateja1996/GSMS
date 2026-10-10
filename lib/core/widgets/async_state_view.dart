import 'package:flutter/material.dart';

enum ViewState { loading, success, empty, error, offline, syncing }

class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.state,
    this.loadingWidget,
    this.emptyWidget,
    this.errorWidget,
    this.offlineWidget,
    this.syncingWidget,
    required this.child,
  });

  final ViewState state;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final Widget? offlineWidget;
  final Widget? syncingWidget;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ViewState.loading =>
        loadingWidget ?? const Center(child: CircularProgressIndicator()),
      ViewState.empty => emptyWidget ?? const EmptyStateView(message: 'No data'),
      ViewState.error =>
        errorWidget ??
            const EmptyStateView(
              icon: Icons.error_outline,
              message: 'Something went wrong',
            ),
      ViewState.offline =>
        offlineWidget ??
            const EmptyStateView(
              icon: Icons.cloud_off,
              message: 'You are offline',
            ),
      ViewState.syncing =>
        syncingWidget ??
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Syncing…'),
                ],
              ),
            ),
      ViewState.success => child,
    };
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: context.theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.theme.textTheme.titleMedium,
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

extension on BuildContext {
  ThemeData get theme => Theme.of(this);
}
