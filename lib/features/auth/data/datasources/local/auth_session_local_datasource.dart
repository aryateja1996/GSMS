import 'dart:convert';

import 'package:gsma/core/constants/storage_keys.dart';
import 'package:gsma/features/auth/data/models/app_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionLocalDataSource {
  static const _userKey = 'cached_app_user';

  Future<void> cacheUser(AppUserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toCacheJson()));
    await prefs.setString(StorageKeys.lastSelectedStoreId, user.storeId);
  }

  Future<AppUserModel?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return AppUserModel.fromCacheJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
