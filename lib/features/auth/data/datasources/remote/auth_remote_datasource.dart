import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gsma/core/exceptions/app_exception.dart';
import 'package:gsma/features/auth/data/models/app_user_model.dart';

class AuthRemoteDataSource {
  FirebaseAuth? get _auth {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance;
  }

  FirebaseFirestore? get _firestore {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  Stream<User?> authStateChanges() {
    final auth = _auth;
    if (auth == null) return Stream<User?>.value(null);
    return auth.authStateChanges();
  }

  User? get currentFirebaseUser => _auth?.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      throw AppException(
        'Cloud sign-in is unavailable. Configure Firebase with flutterfire configure.',
        code: 'FIREBASE_NOT_CONFIGURED',
      );
    }
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapAuthError(e), code: e.code);
    }
  }

  Future<void> signOut() async {
    final auth = _auth;
    if (auth == null) return;
    await auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _auth;
    if (auth == null) {
      throw AppException(
        'Password reset requires Firebase configuration.',
        code: 'FIREBASE_NOT_CONFIGURED',
      );
    }
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapAuthError(e), code: e.code);
    }
  }

  Future<AppUserModel> fetchUserProfile(String uid) async {
    final firestore = _firestore;
    if (firestore == null) {
      throw AppException(
        'Cannot load user profile without Firebase.',
        code: 'FIREBASE_NOT_CONFIGURED',
      );
    }
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw AppException(
        'Your account is not linked to a store. Contact the owner.',
        code: 'USER_PROFILE_MISSING',
      );
    }
    final user = AppUserModel.fromFirestore(doc);
    if (!user.isActive) {
      throw AppException(
        'This account has been disabled.',
        code: 'USER_DISABLED',
      );
    }
    if (user.storeId.isEmpty) {
      throw AppException(
        'No store assigned to this account.',
        code: 'STORE_MISSING',
      );
    }
    return user;
  }

  String _mapAuthError(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => 'Enter a valid email address.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' || 'wrong-password' || 'invalid-credential' =>
        'Invalid email or password.',
      'too-many-requests' => 'Too many attempts. Try again later.',
      _ => 'Authentication failed. Please try again.',
    };
  }
}
