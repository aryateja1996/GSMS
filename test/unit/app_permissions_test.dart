import 'package:flutter_test/flutter_test.dart';
import 'package:gsma/core/permissions/app_permissions.dart';
import 'package:gsma/core/permissions/user_role.dart';

void main() {
  test('Owner has full permissions', () {
    final perms = AppPermissions.defaultsForRole(UserRole.owner);
    expect(perms.contains(AppPermissions.canManageUsers), isTrue);
    expect(perms.contains(AppPermissions.canViewProfit), isTrue);
  });

  test('Cashier has limited permissions', () {
    final perms = AppPermissions.defaultsForRole(UserRole.cashier);
    expect(perms.contains(AppPermissions.canManageUsers), isFalse);
    expect(perms.contains(AppPermissions.canGiveDiscount), isTrue);
  });
}
