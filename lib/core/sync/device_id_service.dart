import 'package:get/get.dart';
import 'package:gsma/core/constants/storage_keys.dart';
import 'package:gsma/core/utils/id_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdService extends GetxService {
  late final String deviceId;

  Future<DeviceIdService> init() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(StorageKeys.deviceId);
    if (id == null || id.isEmpty) {
      id = IdGenerator.newId();
      await prefs.setString(StorageKeys.deviceId, id);
    }
    deviceId = id;
    return this;
  }
}
