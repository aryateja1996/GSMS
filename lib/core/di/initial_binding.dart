import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:gsma/core/config/env_config.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:gsma/core/network/connectivity_service.dart';
import 'package:gsma/core/sync/device_id_service.dart';
import 'package:gsma/core/sync/firestore_sync_processor.dart';
import 'package:gsma/core/sync/sync_manager.dart';
import 'package:gsma/core/di/business_binding.dart';
import 'package:gsma/features/auth/presentation/bindings/auth_binding.dart';

class InitialBinding extends Bindings {
  InitialBinding(this.envConfig);

  final EnvConfig envConfig;

  @override
  void dependencies() {
    Get.put<EnvConfig>(envConfig, permanent: true);
    Get.put<IsarService>(IsarService(), permanent: true);
    Get.put<Connectivity>(Connectivity(), permanent: true);
    Get.put<ConnectivityService>(
      ConnectivityService(Get.find<Connectivity>()),
      permanent: true,
    );
    Get.put<DeviceIdService>(DeviceIdService(), permanent: true);
    Get.put<FirestoreSyncProcessor>(
      FirestoreSyncProcessor(Get.find<IsarService>(), Get.find<DeviceIdService>()),
      permanent: true,
    );
    Get.put<SyncManager>(
      SyncManager(
        Get.find<IsarService>(),
        Get.find<ConnectivityService>(),
        Get.find<FirestoreSyncProcessor>(),
      ),
      permanent: true,
    );
    AuthBinding().dependencies();
    BusinessBinding().dependencies();
  }
}
