import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gsma/core/permissions/app_permissions.dart';
import 'package:gsma/core/permissions/user_role.dart';
import 'package:gsma/features/auth/domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.email,
    required super.displayName,
    required super.storeId,
    required super.role,
    required super.permissions,
    super.isActive,
  });

  factory AppUserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final role = UserRoleX.fromString(data['role'] as String? ?? 'cashier');
    final permissions = _permissionsFromFirestore(
      role,
      data['permissions'] as Map<String, dynamic>?,
    );

    return AppUserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      storeId: data['storeId'] as String? ?? '',
      role: role,
      permissions: permissions,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'storeId': storeId,
        'role': role.name,
        'permissions': permissions.toList(),
        'isActive': isActive,
      };

  factory AppUserModel.fromCacheJson(Map<String, dynamic> json) {
    final role = UserRoleX.fromString(json['role'] as String? ?? 'cashier');
    final permList = json['permissions'] as List<dynamic>?;
    return AppUserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
      role: role,
      permissions: _permissionsFromCache(role, permList),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  static Set<String> _permissionsFromFirestore(
    UserRole role,
    Map<String, dynamic>? rawPerms,
  ) {
    if (rawPerms == null || rawPerms.isEmpty) {
      return AppPermissions.defaultsForRole(role);
    }
    return rawPerms.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toSet();
  }

  static Set<String> _permissionsFromCache(UserRole role, List<dynamic>? permList) {
    if (permList == null || permList.isEmpty) {
      return AppPermissions.defaultsForRole(role);
    }
    return permList.map((e) => e.toString()).toSet();
  }

  AppUser toEntity() => AppUser(
        id: id,
        email: email,
        displayName: displayName,
        storeId: storeId,
        role: role,
        permissions: permissions,
        isActive: isActive,
      );
}
