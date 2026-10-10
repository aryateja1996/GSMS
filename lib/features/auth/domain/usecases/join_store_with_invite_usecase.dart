import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/permissions/user_role.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/users/data/datasources/remote/invite_remote_datasource.dart';

class JoinStoreWithInviteInput {
  const JoinStoreWithInviteInput({
    required this.inviteCode,
    required this.displayName,
    required this.email,
    required this.password,
  });

  final String inviteCode;
  final String displayName;
  final String email;
  final String password;
}

class JoinStoreWithInviteUseCase {
  JoinStoreWithInviteUseCase(this._invites);

  final InviteRemoteDataSource _invites;

  Future<Result<void>> call(JoinStoreWithInviteInput input) async {
    if (Firebase.apps.isEmpty) {
      return const ErrorResult(CacheFailure('Firebase is not configured'));
    }

    final code = input.inviteCode.trim().toUpperCase();
    if (code.length < 4) {
      return const ErrorResult(ValidationFailure('Enter a valid invite code'));
    }

    final invite = await _invites.getInvite(code);
    if (invite == null) {
      return const ErrorResult(ValidationFailure('Invite code not found'));
    }
    if (invite['usedBy'] != null) {
      return const ErrorResult(ValidationFailure('This invite was already used'));
    }

    final expiresAt = (invite['expiresAt'] as Timestamp?)?.toDate();
    if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
      return const ErrorResult(ValidationFailure('This invite has expired'));
    }

    final storeId = invite['storeId'] as String? ?? '';
    final role = invite['role'] as String? ?? UserRole.cashier.name;
    final permissions = invite['permissions'] as Map<String, dynamic>? ?? {};

    UserCredential credential;
    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: input.email.trim(),
        password: input.password,
      );
    } on FirebaseAuthException catch (e) {
      return ErrorResult(CacheFailure(_authMessage(e)));
    }

    final uid = credential.user?.uid;
    if (uid == null) {
      return const ErrorResult(CacheFailure('Account creation failed'));
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': input.email.trim(),
        'displayName': input.displayName.trim(),
        'storeId': storeId,
        'role': role,
        'permissions': permissions,
        'isActive': true,
        'inviteId': code,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _invites.markInviteUsed(code, uid);
    } catch (e) {
      await FirebaseAuth.instance.currentUser?.delete();
      return ErrorResult(CacheFailure('Could not complete join: $e'));
    }

    return const Success(null);
  }

  String _authMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email already registered — sign in instead';
      case 'weak-password':
        return 'Password is too weak (min 6 characters)';
      default:
        return e.message ?? 'Could not create account';
    }
  }
}
