import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gsma/core/database/isar_service.dart';
import 'package:gsma/core/network/connectivity_service.dart';
import 'package:gsma/core/permissions/app_permissions.dart';
import 'package:gsma/core/permissions/user_role.dart';
import 'package:gsma/core/sync/sync_manager.dart';
import 'package:gsma/features/auth/domain/entities/app_user.dart';
import 'package:gsma/features/auth/data/datasources/local/auth_session_local_datasource.dart';
import 'package:gsma/features/auth/domain/usecases/check_store_setup_usecase.dart';
import 'package:gsma/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:gsma/features/auth/domain/usecases/register_first_owner_usecase.dart';
import 'package:gsma/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:gsma/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:gsma/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:gsma/features/auth/presentation/controllers/auth_controller.dart';
import 'package:gsma/core/sync/device_id_service.dart';
import 'package:gsma/core/sync/firestore_sync_processor.dart';
import 'package:gsma/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:gsma/features/dashboard/presentation/pages/dashboard_page.dart';

import 'fakes/fake_auth_repository.dart';
import 'fakes/fake_store_setup_remote.dart';
import 'package:gsma/features/shell/presentation/controllers/main_shell_controller.dart';
import 'package:gsma/features/shell/presentation/pages/main_shell_page.dart';

import 'fakes/fake_reports_repository.dart';
import 'fakes/stub_services.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('Dashboard page shows business overview', (tester) async {
    Get.testMode = true;
    Get.put(DashboardController(FakeReportsRepository()));
    await tester.pumpWidget(
      const GetMaterialApp(home: DashboardPage()),
    );
    expect(find.text('Business overview'), findsOneWidget);
    expect(find.text('Quick actions'), findsOneWidget);
  });

  testWidgets('Main shell loads dashboard tab', (tester) async {
    Get.testMode = true;
    final repo = FakeAuthRepository();
    final setupRemote = FakeStoreSetupRemoteDataSource();
    Get.put(
      AuthController(
        signInUseCase: SignInUseCase(repo),
        signOutUseCase: SignOutUseCase(repo),
        sendPasswordResetUseCase: SendPasswordResetUseCase(repo),
        getCurrentUserUseCase: GetCurrentUserUseCase(repo),
        checkStoreSetupUseCase: CheckStoreSetupUseCase(setupRemote),
        registerFirstOwnerUseCase: RegisterFirstOwnerUseCase(setupRemote),
        sessionLocal: AuthSessionLocalDataSource(),
      ),
      permanent: true,
    );
    Get.find<AuthController>().user.value = AppUser(
      id: 'test',
      email: 'test@example.com',
      displayName: 'Test',
      storeId: 'store1',
      role: UserRole.owner,
      permissions: AppPermissions.defaultsForRole(UserRole.owner),
    );
    Get.put<IsarService>(IsarService(), permanent: true);
    Get.put(DashboardController(FakeReportsRepository()));
    Get.put<ConnectivityService>(StubConnectivityService(), permanent: true);
    Get.put<DeviceIdService>(DeviceIdService(), permanent: true);
    Get.put<FirestoreSyncProcessor>(
      stubSyncProcessor(Get.find<IsarService>(), Get.find<DeviceIdService>()),
      permanent: true,
    );
    Get.put<SyncManager>(
      StubSyncManager(
        Get.find<IsarService>(),
        Get.find<ConnectivityService>(),
        Get.find<FirestoreSyncProcessor>(),
      ),
      permanent: true,
    );
    await Get.find<ConnectivityService>().init();
    await Get.find<SyncManager>().init();
    Get.put(MainShellController());

    await tester.pumpWidget(
      const GetMaterialApp(home: MainShellPage()),
    );

    expect(find.text('Business overview'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
  });
}
