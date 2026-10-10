import 'package:gsma/features/notifications/domain/entities/app_alert.dart';

abstract class NotificationsRepository {
  Future<List<AppAlert>> loadAlerts();
}
