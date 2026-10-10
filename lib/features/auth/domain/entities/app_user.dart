import 'package:equatable/equatable.dart';
import 'package:gsma/core/permissions/user_role.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.storeId,
    required this.role,
    required this.permissions,
    this.isActive = true,
  });

  final String id;
  final String email;
  final String displayName;
  final String storeId;
  final UserRole role;
  final Set<String> permissions;
  final bool isActive;

  bool hasPermission(String permission) => permissions.contains(permission);

  @override
  List<Object?> get props =>
      [id, email, displayName, storeId, role, permissions, isActive];
}
