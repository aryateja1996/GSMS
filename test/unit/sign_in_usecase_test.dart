import 'package:flutter_test/flutter_test.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/auth/domain/usecases/sign_in_usecase.dart';

import '../fakes/fake_auth_repository.dart';

void main() {
  test('SignInUseCase rejects empty email', () async {
    final useCase = SignInUseCase(FakeAuthRepository());
    final result = await useCase(email: '', password: 'secret');
    expect(result, isA<ErrorResult>());
  });
}
