import 'package:gsma/features/auth/domain/entities/app_user.dart';
import 'package:gsma/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppUser?> call() => _repository.getCurrentUser();
}
