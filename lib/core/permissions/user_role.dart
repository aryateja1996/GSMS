enum UserRole {
  owner,
  manager,
  cashier,
  stockManager,
  accountant,
}

extension UserRoleX on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.manager:
        return 'Manager';
      case UserRole.cashier:
        return 'Cashier';
      case UserRole.stockManager:
        return 'Stock Manager';
      case UserRole.accountant:
        return 'Accountant';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name == _normalize(value),
      orElse: () => UserRole.cashier,
    );
  }

  static String _normalize(String value) {
    final lower = value.toLowerCase().replaceAll(' ', '');
    if (lower == 'stockmanager') return 'stockManager';
    return lower;
  }
}
