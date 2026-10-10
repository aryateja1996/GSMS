class StoreSettings {
  const StoreSettings({
    required this.storeName,
    required this.address,
    required this.phone,
    required this.email,
    required this.gstNumber,
    required this.currencySymbol,
    required this.invoicePrefix,
    required this.defaultTaxRate,
    required this.defaultLowStock,
    required this.notificationsEnabled,
  });

  final String storeName;
  final String address;
  final String phone;
  final String email;
  final String gstNumber;
  final String currencySymbol;
  final String invoicePrefix;
  final double defaultTaxRate;
  final double defaultLowStock;
  final bool notificationsEnabled;

  StoreSettings copyWith({
    String? storeName,
    String? address,
    String? phone,
    String? email,
    String? gstNumber,
    String? currencySymbol,
    String? invoicePrefix,
    double? defaultTaxRate,
    double? defaultLowStock,
    bool? notificationsEnabled,
  }) {
    return StoreSettings(
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gstNumber: gstNumber ?? this.gstNumber,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      defaultLowStock: defaultLowStock ?? this.defaultLowStock,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
