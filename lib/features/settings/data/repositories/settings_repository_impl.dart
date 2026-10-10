import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gsma/core/audit/audit_log_service.dart';
import 'package:gsma/core/constants/app_constants.dart';
import 'package:gsma/core/database/datasources/local/app_settings_local_datasource.dart';
import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/settings/domain/entities/store_settings.dart';
import 'package:gsma/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._settings, this._store);

  final AppSettingsLocalDataSource _settings;
  final StoreContext _store;

  String _key() => 'store_settings_${_store.storeId}';

  StoreSettings _defaults() => StoreSettings(
        storeName: '',
        address: '',
        phone: '',
        email: '',
        gstNumber: '',
        currencySymbol: AppConstants.defaultCurrencySymbol,
        invoicePrefix: AppConstants.defaultInvoicePrefix,
        defaultTaxRate: 0,
        defaultLowStock: AppConstants.defaultLowStockThreshold.toDouble(),
        notificationsEnabled: true,
      );

  @override
  Future<StoreSettings> load() async {
    if (!_store.hasStore) return _defaults();
    final raw = await _settings.readString(_key());
    if (raw == null) return _defaults();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return StoreSettings(
        storeName: map['storeName'] as String? ?? '',
        address: map['address'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        email: map['email'] as String? ?? '',
        gstNumber: map['gstNumber'] as String? ?? '',
        currencySymbol: map['currencySymbol'] as String? ?? AppConstants.defaultCurrencySymbol,
        invoicePrefix: map['invoicePrefix'] as String? ?? AppConstants.defaultInvoicePrefix,
        defaultTaxRate: (map['defaultTaxRate'] as num?)?.toDouble() ?? 0,
        defaultLowStock: (map['defaultLowStock'] as num?)?.toDouble() ??
            AppConstants.defaultLowStockThreshold.toDouble(),
        notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      );
    } catch (_) {
      return _defaults();
    }
  }

  @override
  Future<Result<StoreSettings>> save(StoreSettings settings) async {
    if (!_store.hasStore) {
      return const ErrorResult(CacheFailure('No store selected'));
    }
    final previous = await load();
    final json = jsonEncode({
      'storeName': settings.storeName,
      'address': settings.address,
      'phone': settings.phone,
      'email': settings.email,
      'gstNumber': settings.gstNumber,
      'currencySymbol': settings.currencySymbol,
      'invoicePrefix': settings.invoicePrefix,
      'defaultTaxRate': settings.defaultTaxRate,
      'defaultLowStock': settings.defaultLowStock,
      'notificationsEnabled': settings.notificationsEnabled,
    });
    await _settings.writeString(_key(), json);

    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('stores').doc(_store.storeId).set(
          {
            'name': settings.storeName,
            'address': settings.address,
            'phone': settings.phone,
            'email': settings.email,
            'gstNumber': settings.gstNumber,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } catch (_) {
        // Local save still succeeds offline.
      }
    }

    await AuditLogService.optional?.record(
      action: 'settings_updated',
      entityType: 'store',
      entityId: _store.storeId,
      oldValue: {'storeName': previous.storeName},
      newValue: {'storeName': settings.storeName},
    );

    return Success(settings);
  }
}
