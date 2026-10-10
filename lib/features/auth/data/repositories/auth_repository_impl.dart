import 'dart:async';

import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/exceptions/app_exception.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/auth/data/datasources/local/auth_session_local_datasource.dart';
import 'package:gsma/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:gsma/features/auth/domain/entities/app_user.dart';
import 'package:gsma/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthSessionLocalDataSource _local;

  final _authStateController = StreamController<AppUser?>.broadcast();
  StreamSubscription<dynamic>? _firebaseSub;
  AppUser? _memoryUser;

  void startListening() {
    _firebaseSub ??= _remote.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        _memoryUser = null;
        await _local.clear();
        _authStateController.add(null);
        return;
      }
      try {
        final profile = await _remote.fetchUserProfile(firebaseUser.uid);
        _memoryUser = profile.toEntity();
        await _local.cacheUser(profile);
        _authStateController.add(_memoryUser);
      } on AppException {
        _memoryUser = null;
        await _local.clear();
        _authStateController.add(null);
      }
    });
  }

  @override
  Stream<AppUser?> watchAuthState() {
    startListening();
    return _authStateController.stream;
  }

  @override
  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _remote.signInWithEmail(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        return const ErrorResult(AuthFailure('Sign-in failed.'));
      }
      final profile = await _remote.fetchUserProfile(uid);
      _memoryUser = profile.toEntity();
      await _local.cacheUser(profile);
      _authStateController.add(_memoryUser);
      return Success(_memoryUser!);
    } on AppException catch (e) {
      return ErrorResult(AuthFailure(e.message, code: e.code));
    } catch (_) {
      return const ErrorResult(
        AuthFailure('Unable to sign in. Check your connection.'),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remote.signOut();
      _memoryUser = null;
      await _local.clear();
      _authStateController.add(null);
      return const Success(null);
    } on AppException catch (e) {
      return ErrorResult(AuthFailure(e.message, code: e.code));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _remote.sendPasswordResetEmail(email);
      return const Success(null);
    } on AppException catch (e) {
      return ErrorResult(AuthFailure(e.message, code: e.code));
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    if (_memoryUser != null) return _memoryUser;
    final firebaseUser = _remote.currentFirebaseUser;
    if (firebaseUser != null) {
      try {
        final profile = await _remote.fetchUserProfile(firebaseUser.uid);
        _memoryUser = profile.toEntity();
        await _local.cacheUser(profile);
        return _memoryUser;
      } on AppException {
        return null;
      }
    }
    final cached = await _local.getCachedUser();
    _memoryUser = cached?.toEntity();
    return _memoryUser;
  }

  Future<void> dispose() async {
    await _firebaseSub?.cancel();
    await _authStateController.close();
  }
}
