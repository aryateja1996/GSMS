import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.signOut();
}
