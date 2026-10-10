import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/app/gsma_app.dart';
import 'package:gsma/core/config/app_environment.dart';
import 'package:gsma/core/config/env_config.dart';
import 'package:gsma/core/constants/storage_keys.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:gsma/core/di/initial_binding.dart';
import 'package:gsma/core/network/connectivity_service.dart';
import 'package:gsma/core/sync/device_id_service.dart';
import 'package:gsma/core/sync/sync_manager.dart';
import 'package:gsma/firebase/firebase_bootstrap.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final env = AppEnvironment.fromString(prefs.getString(StorageKeys.environment));
  final envConfig = EnvConfig(environment: env);

  await initializeFirebase(envConfig);

  InitialBinding(envConfig).dependencies();

  await Get.find<IsarService>().init();
  await Get.find<ConnectivityService>().init();
  await Get.find<DeviceIdService>().init();
  await Get.find<SyncManager>().init();

  runApp(const GsmaApp());
}
