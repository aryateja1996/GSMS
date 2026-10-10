import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/auth/domain/entities/app_user.dart';
import 'package:gsma/features/auth/domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<AppUser?> getCurrentUser() async => null;

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async =>
      const Success(null);

  @override
  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async =>
      const ErrorResult(AuthFailure('not used'));

  @override
  Future<Result<void>> signOut() async => const Success(null);

  @override
  Stream<AppUser?> watchAuthState() => const Stream.empty();
}
