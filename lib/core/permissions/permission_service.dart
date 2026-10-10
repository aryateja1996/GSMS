import 'package:get/get.dart';
import 'package:gsma/features/auth/presentation/controllers/auth_controller.dart';

class PermissionService extends GetxService {
  bool can(String permission) {
    if (!Get.isRegistered<AuthController>()) return false;
    return Get.find<AuthController>().hasPermission(permission);
  }
}
