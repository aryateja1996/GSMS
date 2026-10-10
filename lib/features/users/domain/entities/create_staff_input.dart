import 'package:gsma/core/permissions/user_role.dart';

class CreateStaffInput {
  const CreateStaffInput({
    required this.email,
    required this.password,
    required this.displayName,
    required this.role,
    required this.permissions,
  });

  final String email;
  final String password;
  final String displayName;
  final UserRole role;
  final Set<String> permissions;
}

class StaffInviteResult {
  const StaffInviteResult({
    required this.code,
    required this.expiresAt,
    required this.role,
  });

  final String code;
  final DateTime expiresAt;
  final UserRole role;
}
