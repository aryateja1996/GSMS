import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gsma/core/exceptions/app_exception.dart';
import 'package:gsma/core/utils/app_logger.dart';
import 'package:gsma/core/permissions/app_permissions.dart';
import 'package:gsma/core/permissions/user_role.dart';
import 'package:gsma/core/utils/id_generator.dart';
import 'package:gsma/features/auth/data/models/app_user_model.dart';

class StoreSetupRemoteDataSource {
  FirebaseAuth? get _auth {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance;
  }

  FirebaseFirestore? get _firestore {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  Future<bool> isStoreSetupComplete() async {
    final firestore = _firestore;
    if (firestore == null) return false;
    return _hasActiveRegisteredStore(firestore);
  }

  /// Setup is "complete" only when config says so and the linked store doc exists.
  Future<bool> _hasActiveRegisteredStore(FirebaseFirestore firestore) async {
    final config = await _getConfigDoc(firestore, preferServer: true);
    if (!config.exists) return false;

    final data = config.data();
    if (data?['setupComplete'] != true) return false;

    final storeId = data?['storeId'] as String?;
    if (storeId == null || storeId.isEmpty) {
      AppLogger.warning(
        'config/app marked complete but storeId is missing — allowing setup',
        tag: 'Auth',
      );
      return false;
    }

    final store = await _getStoreDoc(firestore, storeId, preferServer: true);
    if (!store.exists) {
      AppLogger.warning(
        'config/app points to missing store $storeId — allowing setup',
        tag: 'Auth',
      );
      return false;
    }

    return true;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getConfigDoc(
    FirebaseFirestore firestore, {
    required bool preferServer,
  }) {
    final ref = firestore.collection('config').doc('app');
    return _getDoc(ref, preferServer: preferServer);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getStoreDoc(
    FirebaseFirestore firestore,
    String storeId, {
    required bool preferServer,
  }) {
    final ref = firestore.collection('stores').doc(storeId);
    return _getDoc(ref, preferServer: preferServer);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getDoc(
    DocumentReference<Map<String, dynamic>> ref, {
    required bool preferServer,
  }) async {
    if (!preferServer) return ref.get();
    try {
      return await ref.get(const GetOptions(source: Source.server));
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        return ref.get(const GetOptions(source: Source.cache));
      }
      rethrow;
    }
  }

  Future<AppUserModel> registerFirstOwner({
    required String storeName,
    String? storeAddress,
    String? storePhone,
    required String ownerName,
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) {
      throw AppException(
        'Firebase is not configured.',
        code: 'FIREBASE_NOT_CONFIGURED',
      );
    }

    if (await _hasActiveRegisteredStore(firestore)) {
      throw AppException(
        'A store is already registered for this app. Sign in with the owner account, '
        'or use an invite code to join the team.',
        code: 'SETUP_ALREADY_COMPLETE',
      );
    }

    UserCredential credential;
    try {
      credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapAuthError(e), code: e.code);
    }

    final uid = credential.user?.uid;
    if (uid == null) {
      throw AppException('Could not create account.', code: 'AUTH_FAILED');
    }

    final storeId = IdGenerator.newId();
    final now = FieldValue.serverTimestamp();
    final ownerPerms = AppPermissions.defaultsForRole(UserRole.owner);
    final permissionsMap = {for (final p in ownerPerms) p: true};

    try {
      final batch = firestore.batch();

      batch.set(firestore.collection('stores').doc(storeId), {
        'storeId': storeId,
        'name': storeName,
        'address': storeAddress ?? '',
        'phone': storePhone ?? '',
        'createdAt': now,
        'updatedAt': now,
        'createdBy': uid,
        'updatedBy': uid,
      });

      batch.set(firestore.collection('users').doc(uid), {
        'email': email,
        'displayName': ownerName,
        'storeId': storeId,
        'role': UserRole.owner.name,
        'permissions': permissionsMap,
        'isActive': true,
        'createdAt': now,
        'updatedAt': now,
        'createdBy': uid,
        'updatedBy': uid,
      });

      batch.set(
        firestore.collection('config').doc('app'),
        {
          'setupComplete': true,
          'storeId': storeId,
          'ownerId': uid,
          'completedAt': now,
        },
        SetOptions(merge: true),
      );

      await batch.commit();
    } on FirebaseException catch (e) {
      AppLogger.warning('Store setup Firestore error: ${e.code} ${e.message}', tag: 'Auth');
      try {
        await credential.user?.delete();
      } catch (_) {}
      await auth.signOut();
      final hint = switch (e.code) {
        'permission-denied' =>
          'Firestore denied setup. Deploy the latest rules (firebase deploy --only firestore:rules) '
          'and ensure Email/Password sign-in is enabled.',
        _ => e.message ?? e.code,
      };
      throw AppException(
        'Could not save store data: $hint',
        code: 'SETUP_WRITE_FAILED',
      );
    } catch (e) {
      AppLogger.warning('Store setup failed: $e', tag: 'Auth');
      try {
        await credential.user?.delete();
      } catch (_) {}
      await auth.signOut();
      throw AppException(
        'Could not save store data. Check your connection and Firestore rules.',
        code: 'SETUP_WRITE_FAILED',
      );
    }

    final profile = await firestore.collection('users').doc(uid).get();
    return AppUserModel.fromFirestore(profile);
  }

  String _mapAuthError(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => 'Enter a valid email address.',
      'email-already-in-use' =>
        'This email is already registered. Try signing in.',
      'weak-password' => 'Use a password with at least 6 characters.',
      'operation-not-allowed' =>
        'Email/password sign-up is disabled in Firebase Console. Enable it under Authentication.',
      _ => 'Could not create account. Please try again.',
    };
  }
}
