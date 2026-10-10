import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/settings/domain/entities/store_settings.dart';

abstract class SettingsRepository {
  Future<StoreSettings> load();

  Future<Result<StoreSettings>> save(StoreSettings settings);
}
