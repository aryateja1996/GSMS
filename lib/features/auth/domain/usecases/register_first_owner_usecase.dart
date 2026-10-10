import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/exceptions/app_exception.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/core/validators/form_validators.dart';
import 'package:gsma/features/auth/data/datasources/remote/store_setup_remote_datasource.dart';
import 'package:gsma/features/auth/domain/entities/app_user.dart';

class RegisterFirstOwnerUseCase {
  RegisterFirstOwnerUseCase(this._remote);

  final StoreSetupRemoteDataSource _remote;

  Future<Result<AppUser>> call({
    required String storeName,
    String? storeAddress,
    String? storePhone,
    required String ownerName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final storeError = FormValidators.required(storeName, field: 'Store name');
    if (storeError != null) return ErrorResult(ValidationFailure(storeError));

    final nameError = FormValidators.required(ownerName, field: 'Your name');
    if (nameError != null) return ErrorResult(ValidationFailure(nameError));

    final emailError = FormValidators.required(email, field: 'Email');
    if (emailError != null) return ErrorResult(ValidationFailure(emailError));

    final passwordError = FormValidators.password(password);
    if (passwordError != null) return ErrorResult(ValidationFailure(passwordError));

    if (password != confirmPassword) {
      return const ErrorResult(ValidationFailure('Passwords do not match'));
    }

    try {
      final model = await _remote.registerFirstOwner(
        storeName: storeName.trim(),
        storeAddress: storeAddress?.trim(),
        storePhone: storePhone?.trim(),
        ownerName: ownerName.trim(),
        email: email.trim(),
        password: password,
      );
      return Success(model.toEntity());
    } on AppException catch (e) {
      return ErrorResult(AuthFailure(e.message, code: e.code));
    }
  }
}
