import 'package:get/get.dart';
import 'package:gsma/core/permissions/app_permissions.dart';
import 'package:gsma/core/permissions/user_role.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/auth/domain/entities/app_user.dart';
import 'package:gsma/features/users/domain/entities/create_staff_input.dart';
import 'package:gsma/features/users/domain/repositories/staff_repository.dart';

class UsersController extends GetxController {
  UsersController(this._staff);

  final StaffRepository _staff;

  final RxList<AppUser> items = <AppUser>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      items.assignAll(await _staff.listStaff());
    } catch (e) {
      errorMessage.value = 'Could not load team (need online + Firestore)';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateUser({
    required AppUser user,
    required UserRole role,
    required Set<String> permissions,
    required bool isActive,
  }) async {
    final result = await _staff.updateStaff(
      userId: user.id,
      role: role,
      permissions: permissions,
      isActive: isActive,
    );
    switch (result) {
      case Success():
        await load();
        return true;
      case ErrorResult(failure: final f):
        errorMessage.value = f.message;
        return false;
    }
  }

  Set<String> allPermissionKeys() => AppPermissions.defaultsForRole(UserRole.owner);

  Future<bool> createStaff(CreateStaffInput input) async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await _staff.createStaff(input);
    isLoading.value = false;
    switch (result) {
      case Success():
        await load();
        return true;
      case ErrorResult(failure: final f):
        errorMessage.value = f.message;
        return false;
    }
  }

  Future<Result<StaffInviteResult>> createInvite({
    required UserRole role,
    required Set<String> permissions,
  }) {
    return _staff.createInvite(role: role, permissions: permissions);
  }
}
