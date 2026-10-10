import 'dart:convert';

import 'package:gsma/core/constants/app_constants.dart';
import 'package:gsma/core/database/collections/local_app_setting.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:isar/isar.dart';

class InvoiceNumberService {
  InvoiceNumberService(this._isar);

  final IsarService _isar;

  Future<String> nextInvoiceNumber(String storeId) async {
    final key = 'invoice_seq_$storeId';
    final isar = _isar.isar;
    var seq = 1;

    await isar.writeTxn(() async {
      final existing = await isar.localAppSettings
          .filter()
          .keyEqualTo(key)
          .findFirst();
      if (existing != null) {
        final data = jsonDecode(existing.valueJson) as Map<String, dynamic>;
        seq = (data['seq'] as num?)?.toInt() ?? 1;
        seq += 1;
        existing.valueJson = jsonEncode({'seq': seq});
        existing.updatedAt = DateTime.now();
        await isar.localAppSettings.put(existing);
      } else {
        final setting = LocalAppSetting()
          ..key = key
          ..valueJson = jsonEncode({'seq': seq})
          ..updatedAt = DateTime.now();
        await isar.localAppSettings.put(setting);
      }
    });

    return '${AppConstants.defaultInvoicePrefix}-${seq.toString().padLeft(6, '0')}';
  }
}
