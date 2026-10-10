import 'package:gsma/core/permissions/user_role.dart';

/// Permission flags enforced in UI and mirrored in Firestore rules (Phase 12).
abstract final class AppPermissions {
  static const canViewReports = 'canViewReports';
  static const canEditProducts = 'canEditProducts';
  static const canManageStock = 'canManageStock';
  static const canCreatePurchase = 'canCreatePurchase';
  static const canManageKhata = 'canManageKhata';
  static const canGiveDiscount = 'canGiveDiscount';
  static const canRefund = 'canRefund';
  static const canManageUsers = 'canManageUsers';
  static const canViewProfit = 'canViewProfit';
  static const canModifySettings = 'canModifySettings';

  static Set<String> defaultsForRole(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return {
          canViewReports,
          canEditProducts,
          canManageStock,
          canCreatePurchase,
          canManageKhata,
          canGiveDiscount,
          canRefund,
          canManageUsers,
          canViewProfit,
          canModifySettings,
        };
      case UserRole.manager:
        return {
          canViewReports,
          canEditProducts,
          canManageStock,
          canCreatePurchase,
          canManageKhata,
          canGiveDiscount,
          canRefund,
          canViewProfit,
        };
      case UserRole.cashier:
        return {canGiveDiscount, canManageKhata};
      case UserRole.stockManager:
        return {canEditProducts, canManageStock, canCreatePurchase};
      case UserRole.accountant:
        return {
          canViewReports,
          canManageKhata,
          canViewProfit,
          canCreatePurchase,
        };
    }
  }
}
