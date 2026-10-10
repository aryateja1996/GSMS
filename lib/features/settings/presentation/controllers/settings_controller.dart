import 'package:get/get.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/settings/domain/entities/store_settings.dart';
import 'package:gsma/features/settings/domain/repositories/settings_repository.dart';

class SettingsController extends GetxController {
  SettingsController(this._settings);

  final SettingsRepository _settings;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<StoreSettings> current = Rxn<StoreSettings>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    current.value = await _settings.load();
    isLoading.value = false;
  }

  Future<bool> save(StoreSettings settings) async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await _settings.save(settings);
    isLoading.value = false;
    switch (result) {
      case Success(value: final s):
        current.value = s;
        return true;
      case ErrorResult(failure: final f):
        errorMessage.value = f.message;
        return false;
    }
  }
}
