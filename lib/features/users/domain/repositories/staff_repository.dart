import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/auth/domain/entities/app_user.dart';
import 'package:gsma/core/permissions/user_role.dart';
import 'package:gsma/features/users/domain/entities/create_staff_input.dart';

abstract class StaffRepository {
  Future<List<AppUser>> listStaff();

  Future<Result<String>> createStaff(CreateStaffInput input);

  Future<Result<StaffInviteResult>> createInvite({
    required UserRole role,
    required Set<String> permissions,
  });

  Future<Result<void>> updateStaff({
    required String userId,
    required UserRole role,
    required Set<String> permissions,
    required bool isActive,
  });
}
