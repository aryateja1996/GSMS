import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/core/validators/form_validators.dart';
import 'package:gsma/features/auth/domain/entities/app_user.dart';
import 'package:gsma/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AppUser>> call({
    required String email,
    required String password,
  }) async {
    final emailError = FormValidators.required(email, field: 'Email');
    if (emailError != null) {
      return ErrorResult(ValidationFailure(emailError));
    }
    final passwordError = FormValidators.required(password, field: 'Password');
    if (passwordError != null) {
      return ErrorResult(ValidationFailure(passwordError));
    }
    return _repository.signInWithEmail(
      email: email.trim(),
      password: password,
    );
  }
}
