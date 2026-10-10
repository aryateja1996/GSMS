enum AppEnvironment {
  development,
  staging,
  production;

  bool get isProduction => this == AppEnvironment.production;

  static AppEnvironment fromString(String? value) {
    if (value == null || value.isEmpty) return AppEnvironment.development;
    return AppEnvironment.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppEnvironment.development,
    );
  }
}
