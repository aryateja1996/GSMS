import 'package:get/get.dart';
import 'package:gsma/features/auth/presentation/controllers/auth_controller.dart';

class StoreContext extends GetxService {
  String get storeId =>
      Get.find<AuthController>().user.value?.storeId ?? '';

  String get userId => Get.find<AuthController>().user.value?.id ?? '';

  bool get hasStore => storeId.isNotEmpty;
}
