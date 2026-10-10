import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> watchAuthState();

  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<AppUser?> getCurrentUser();
}
