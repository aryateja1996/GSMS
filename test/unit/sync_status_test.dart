import 'package:flutter_test/flutter_test.dart';
import 'package:gsma/core/sync/sync_status.dart';

void main() {
  test('SyncStatus.fromString parses known values', () {
    expect(syncStatusFromString('pending'), SyncStatus.pending);
    expect(syncStatusFromString('SYNCED'), SyncStatus.synced);
    expect(syncStatusFromString('unknown'), SyncStatus.pending);
  });
}
