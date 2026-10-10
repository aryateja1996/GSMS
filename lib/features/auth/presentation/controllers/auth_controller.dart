import 'dart:async';

import 'package:get/get.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/auth/domain/entities/app_user.dart';
import 'package:gsma/features/auth/data/datasources/local/auth_session_local_datasource.dart';
import 'package:gsma/features/auth/data/models/app_user_model.dart';
import 'package:gsma/features/auth/domain/usecases/check_store_setup_usecase.dart';
import 'package:gsma/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:gsma/features/auth/domain/usecases/register_first_owner_usecase.dart';
import 'package:gsma/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:gsma/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:gsma/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:gsma/routes/app_routes.dart';

enum AuthUiState { idle, loading, success, error }

class AuthController extends GetxController {
  AuthController({
    required SignInUseCase signInUseCase,
    required SignOutUseCase signOutUseCase,
    required SendPasswordResetUseCase sendPasswordResetUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required CheckStoreSetupUseCase checkStoreSetupUseCase,
    required RegisterFirstOwnerUseCase registerFirstOwnerUseCase,
    required AuthSessionLocalDataSource sessionLocal,
  })  : _signInUseCase = signInUseCase,
        _signOutUseCase = signOutUseCase,
        _sendPasswordResetUseCase = sendPasswordResetUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _checkStoreSetupUseCase = checkStoreSetupUseCase,
        _registerFirstOwnerUseCase = registerFirstOwnerUseCase,
        _sessionLocal = sessionLocal;

  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final SendPasswordResetUseCase _sendPasswordResetUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final CheckStoreSetupUseCase _checkStoreSetupUseCase;
  final RegisterFirstOwnerUseCase _registerFirstOwnerUseCase;
  final AuthSessionLocalDataSource _sessionLocal;

  final Rxn<AppUser> user = Rxn<AppUser>();
  final Rx<AuthUiState> uiState = AuthUiState.idle.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<AppUser?>? _authSub;

  bool get isAuthenticated => user.value != null;

  bool hasPermission(String permission) =>
      user.value?.hasPermission(permission) ?? false;

  @override
  void onInit() {
    super.onInit();
    _loadSession();
  }

  Future<void> _loadSession() async {
    user.value = await _getCurrentUserUseCase();
  }

  Future<void> refreshSession() async => _loadSession();

  Future<void> resolveInitialRoute() async {
    uiState.value = AuthUiState.loading;
    await _loadSession();
    uiState.value = AuthUiState.idle;
    if (isAuthenticated) {
      Get.offAllNamed(AppRoutes.mainShell);
      return;
    }
    final setupDone = await _checkStoreSetupUseCase();
    if (!setupDone) {
      Get.offAllNamed(AppRoutes.storeSetup);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> registerFirstOwner({
    required String storeName,
    String? storeAddress,
    String? storePhone,
    required String ownerName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    uiState.value = AuthUiState.loading;
    errorMessage.value = '';
    final result = await _registerFirstOwnerUseCase(
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      ownerName: ownerName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    switch (result) {
      case Success(value: final appUser):
        user.value = appUser;
        await _sessionLocal.cacheUser(
          AppUserModel(
            id: appUser.id,
            email: appUser.email,
            displayName: appUser.displayName,
            storeId: appUser.storeId,
            role: appUser.role,
            permissions: appUser.permissions,
            isActive: appUser.isActive,
          ),
        );
        uiState.value = AuthUiState.success;
        Get.offAllNamed(AppRoutes.mainShell);
      case ErrorResult(failure: final failure):
        uiState.value = AuthUiState.error;
        errorMessage.value = failure.message;
    }
  }

  Future<void> signIn(String email, String password) async {
    uiState.value = AuthUiState.loading;
    errorMessage.value = '';
    final result = await _signInUseCase(email: email, password: password);
    switch (result) {
      case Success(value: final appUser):
        user.value = appUser;
        uiState.value = AuthUiState.success;
        Get.offAllNamed(AppRoutes.mainShell);
      case ErrorResult(failure: final failure):
        uiState.value = AuthUiState.error;
        errorMessage.value = failure.message;
    }
  }

  Future<void> signOut() async {
    uiState.value = AuthUiState.loading;
    final result = await _signOutUseCase();
    switch (result) {
      case Success():
        user.value = null;
        uiState.value = AuthUiState.idle;
        Get.offAllNamed(AppRoutes.login);
      case ErrorResult(failure: final failure):
        uiState.value = AuthUiState.error;
        errorMessage.value = failure.message;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    uiState.value = AuthUiState.loading;
    errorMessage.value = '';
    final result = await _sendPasswordResetUseCase(email);
    switch (result) {
      case Success():
        uiState.value = AuthUiState.success;
        return true;
      case ErrorResult(failure: final failure):
        uiState.value = AuthUiState.error;
        errorMessage.value = failure.message;
        return false;
    }
  }

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }
}
