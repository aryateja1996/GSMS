import 'package:get/get.dart';
import 'package:gsma/features/notifications/domain/entities/app_alert.dart';
import 'package:gsma/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsController extends GetxController {
  NotificationsController(this._notifications);

  final NotificationsRepository _notifications;

  final RxList<AppAlert> alerts = <AppAlert>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      alerts.assignAll(await _notifications.loadAlerts());
    } finally {
      isLoading.value = false;
    }
  }
}
