import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gsma/features/auth/data/models/app_user_model.dart';

class StaffRemoteDataSource {
  FirebaseFirestore? get _firestore =>
      Firebase.apps.isEmpty ? null : FirebaseFirestore.instance;

  Future<List<AppUserModel>> listForStore(String storeId) async {
    final firestore = _firestore;
    if (firestore == null) return [];
    final snap = await firestore
        .collection('users')
        .where('storeId', isEqualTo: storeId)
        .get();
    return snap.docs.map(AppUserModel.fromFirestore).toList();
  }

  Future<String> createStaffMember({
    required String email,
    required String password,
    required String displayName,
    required String role,
    required Map<String, bool> permissions,
  }) async {
    if (Firebase.apps.isEmpty) {
      throw StateError('Firebase not available');
    }
    final callable = FirebaseFunctions.instance.httpsCallable('createStaffMember');
    final result = await callable.call<Map<String, dynamic>>({
      'email': email.trim(),
      'password': password,
      'displayName': displayName.trim(),
      'role': role,
      'permissions': permissions,
    });
    final data = result.data;
    return data['uid'] as String? ?? '';
  }

  Future<void> updateStaff({
    required String userId,
    required String role,
    required Map<String, bool> permissions,
    required bool isActive,
  }) async {
    final firestore = _firestore;
    if (firestore == null) {
      throw StateError('Firebase not available');
    }
    await firestore.collection('users').doc(userId).set(
      {
        'role': role,
        'permissions': permissions,
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
