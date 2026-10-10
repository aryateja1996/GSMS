import 'dart:convert';

import 'package:gsma/core/database/collections/local_app_setting.dart';
import 'package:isar/isar.dart';
import 'package:gsma/core/database/isar_service.dart';

class AppSettingsLocalDataSource {
  AppSettingsLocalDataSource(this._isar);

  final IsarService _isar;

  Future<String?> readString(String key) async {
    final row = await _isar.isar.localAppSettings
        .filter()
        .keyEqualTo(key)
        .findFirst();
    if (row == null) return null;
    try {
      final decoded = jsonDecode(row.valueJson);
      return decoded is String ? decoded : row.valueJson;
    } catch (_) {
      return row.valueJson;
    }
  }

  Future<double?> readDouble(String key) async {
    final raw = await readString(key);
    if (raw == null) return null;
    return double.tryParse(raw);
  }

  Future<void> writeString(String key, String value) async {
    final now = DateTime.now();
    final existing = await _isar.isar.localAppSettings
        .filter()
        .keyEqualTo(key)
        .findFirst();
    final row = existing ?? LocalAppSetting()..key = key;
    row.valueJson = jsonEncode(value);
    row.updatedAt = now;
    await _isar.isar.writeTxn(() async {
      await _isar.isar.localAppSettings.put(row);
    });
  }

  Future<void> writeDouble(String key, double value) =>
      writeString(key, value.toString());
}
