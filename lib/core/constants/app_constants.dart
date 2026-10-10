/// Application-wide constants (non-secret).
abstract final class AppConstants {
  static const String appName = 'GSMA Grocery';
  static const String defaultCurrencySymbol = '₹';
  static const String defaultInvoicePrefix = 'INV';
  static const int defaultLowStockThreshold = 5;
  static const int syncRetryMaxAttempts = 5;
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const Duration connectivityPollInterval = Duration(seconds: 15);
}
