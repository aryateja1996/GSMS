enum AppAlertSeverity { info, warning, critical }

class AppAlert {
  const AppAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    this.route,
  });

  final String id;
  final String title;
  final String message;
  final AppAlertSeverity severity;
  final String? route;
}
