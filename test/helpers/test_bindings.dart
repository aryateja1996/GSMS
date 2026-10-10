import 'dart:io';

import 'package:get/get.dart';
import 'package:gsma/core/config/app_environment.dart';
import 'package:gsma/core/config/env_config.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:gsma/core/di/initial_binding.dart';

Directory? _testDbDir;

/// Full DI + Isar for integration-style tests on device/emulator only.
Future<void> setupTestBindings() async {
  Get.testMode = true;
  if (Get.isRegistered<IsarService>()) {
    await Get.find<IsarService>().close();
    Get.reset();
    Get.testMode = true;
  }

  _testDbDir ??= Directory.systemTemp.createTempSync('gsma_test_isar_');

  InitialBinding(EnvConfig(environment: AppEnvironment.development)).dependencies();
  await Get.find<IsarService>().init(directory: _testDbDir!.path);
}

Future<void> tearDownTestBindings() async {
  if (Get.isRegistered<IsarService>()) {
    await Get.find<IsarService>().close();
  }
  Get.reset();
  if (_testDbDir != null && _testDbDir!.existsSync()) {
    _testDbDir!.deleteSync(recursive: true);
    _testDbDir = null;
  }
}
