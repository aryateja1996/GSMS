import 'package:gsma/core/config/app_environment.dart';

/// Runtime environment configuration (no secrets).
class EnvConfig {
  EnvConfig({required this.environment});

  final AppEnvironment environment;

  bool get enableFirebase => true;
  bool get enableCrashlytics => environment.isProduction;
  bool get enableAnalytics => !environment.isProduction ? true : true;
}
