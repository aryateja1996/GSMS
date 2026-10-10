import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/core/validators/form_validators.dart';
import 'package:gsma/features/auth/domain/repositories/auth_repository.dart';

class SendPasswordResetUseCase {
  SendPasswordResetUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(String email) async {
    final emailError = FormValidators.required(email, field: 'Email');
    if (emailError != null) {
      return ErrorResult(ValidationFailure(emailError));
    }
    return _repository.sendPasswordResetEmail(email.trim());
  }
}
