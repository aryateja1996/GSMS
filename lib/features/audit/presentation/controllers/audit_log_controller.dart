import 'package:get/get.dart';
import 'package:gsma/features/audit/domain/entities/audit_log_entry.dart';
import 'package:gsma/features/audit/domain/repositories/audit_log_repository.dart';

class AuditLogController extends GetxController {
  AuditLogController(this._audit);

  final AuditLogRepository _audit;

  final RxList<AuditLogEntry> items = <AuditLogEntry>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      items.assignAll(await _audit.listRecent());
    } finally {
      isLoading.value = false;
    }
  }
}
