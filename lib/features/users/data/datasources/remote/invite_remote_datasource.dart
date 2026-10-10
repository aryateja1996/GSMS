import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gsma/core/permissions/user_role.dart';

class InviteRemoteDataSource {
  FirebaseFirestore? get _firestore =>
      Firebase.apps.isEmpty ? null : FirebaseFirestore.instance;

  static String _randomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    return List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
  }

  Future<({String code, DateTime expiresAt})> createInvite({
    required String storeId,
    required String createdBy,
    required UserRole role,
    required Map<String, bool> permissions,
    Duration validity = const Duration(days: 7),
  }) async {
    final firestore = _firestore;
    if (firestore == null) {
      throw StateError('Firebase not available');
    }

    final code = _randomCode();
    final expiresAt = DateTime.now().add(validity);
    await firestore.collection('storeInvites').doc(code).set({
      'storeId': storeId,
      'role': role.name,
      'permissions': permissions,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'usedBy': null,
    });
    return (code: code, expiresAt: expiresAt);
  }

  Future<Map<String, dynamic>?> getInvite(String code) async {
    final firestore = _firestore;
    if (firestore == null) return null;
    final snap = await firestore.collection('storeInvites').doc(code.toUpperCase()).get();
    if (!snap.exists) return null;
    return snap.data();
  }

  Future<void> markInviteUsed(String code, String uid) async {
    final firestore = _firestore;
    if (firestore == null) {
      throw StateError('Firebase not available');
    }
    await firestore.collection('storeInvites').doc(code.toUpperCase()).update({
      'usedBy': uid,
      'usedAt': FieldValue.serverTimestamp(),
    });
  }
}
