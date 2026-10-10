import 'package:get/get.dart';
import 'package:gsma/core/permissions/permission_service.dart';
import 'package:gsma/features/auth/data/datasources/local/auth_session_local_datasource.dart';
import 'package:gsma/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:gsma/features/auth/data/datasources/remote/store_setup_remote_datasource.dart';
import 'package:gsma/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gsma/features/auth/domain/repositories/auth_repository.dart';
import 'package:gsma/features/auth/domain/usecases/check_store_setup_usecase.dart';
import 'package:gsma/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:gsma/features/auth/domain/usecases/register_first_owner_usecase.dart';
import 'package:gsma/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:gsma/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:gsma/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:gsma/features/auth/domain/usecases/join_store_with_invite_usecase.dart';
import 'package:gsma/features/auth/presentation/controllers/auth_controller.dart';
import 'package:gsma/features/users/data/datasources/remote/invite_remote_datasource.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthSessionLocalDataSource>()) {
      Get.put(AuthSessionLocalDataSource(), permanent: true);
    }
    if (!Get.isRegistered<AuthRemoteDataSource>()) {
      Get.put(AuthRemoteDataSource(), permanent: true);
    }
    if (!Get.isRegistered<StoreSetupRemoteDataSource>()) {
      Get.put(StoreSetupRemoteDataSource(), permanent: true);
    }
    if (!Get.isRegistered<InviteRemoteDataSource>()) {
      Get.put(InviteRemoteDataSource(), permanent: true);
    }
    if (!Get.isRegistered<JoinStoreWithInviteUseCase>()) {
      Get.put(
        JoinStoreWithInviteUseCase(Get.find<InviteRemoteDataSource>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AuthRepository>()) {
      final repo = AuthRepositoryImpl(
        Get.find<AuthRemoteDataSource>(),
        Get.find<AuthSessionLocalDataSource>(),
      );
      Get.put<AuthRepository>(repo, permanent: true);
      repo.startListening();
    }
    if (!Get.isRegistered<PermissionService>()) {
      Get.put(PermissionService(), permanent: true);
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put(
        AuthController(
          signInUseCase: SignInUseCase(Get.find<AuthRepository>()),
          signOutUseCase: SignOutUseCase(Get.find<AuthRepository>()),
          sendPasswordResetUseCase:
              SendPasswordResetUseCase(Get.find<AuthRepository>()),
          getCurrentUserUseCase: GetCurrentUserUseCase(Get.find<AuthRepository>()),
          checkStoreSetupUseCase:
              CheckStoreSetupUseCase(Get.find<StoreSetupRemoteDataSource>()),
          registerFirstOwnerUseCase: RegisterFirstOwnerUseCase(
            Get.find<StoreSetupRemoteDataSource>(),
          ),
          sessionLocal: Get.find<AuthSessionLocalDataSource>(),
        ),
        permanent: true,
      );
    }
  }
}
