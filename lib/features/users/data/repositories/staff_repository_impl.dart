import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:gsma/core/audit/audit_log_service.dart';
import 'package:gsma/core/errors/failures.dart';
import 'package:gsma/core/permissions/user_role.dart';
import 'package:gsma/core/store/store_context.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/auth/domain/entities/app_user.dart';
import 'package:gsma/features/users/data/datasources/remote/invite_remote_datasource.dart';
import 'package:gsma/features/users/data/datasources/remote/staff_remote_datasource.dart';
import 'package:gsma/features/users/domain/entities/create_staff_input.dart';
import 'package:gsma/features/users/domain/repositories/staff_repository.dart';

class StaffRepositoryImpl implements StaffRepository {
  StaffRepositoryImpl(this._remote, this._invites, this._store);

  final StaffRemoteDataSource _remote;
  final InviteRemoteDataSource _invites;
  final StoreContext _store;

  @override
  Future<List<AppUser>> listStaff() async {
    if (!_store.hasStore) return [];
    final models = await _remote.listForStore(_store.storeId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Result<String>> createStaff(CreateStaffInput input) async {
    if (!_store.hasStore) {
      return const ErrorResult(CacheFailure('No store selected'));
    }
    if (input.role == UserRole.owner) {
      return const ErrorResult(ValidationFailure('Cannot create another owner from the app'));
    }
    try {
      final permMap = {for (final p in input.permissions) p: true};
      final uid = await _remote.createStaffMember(
        email: input.email,
        password: input.password,
        displayName: input.displayName,
        role: input.role.name,
        permissions: permMap,
      );
      await AuditLogService.optional?.record(
        action: 'staff_created',
        entityType: 'user',
        entityId: uid,
        newValue: {'email': input.email, 'role': input.role.name},
      );
      return Success(uid);
    } on FirebaseFunctionsException catch (e) {
      return ErrorResult(CacheFailure(e.message ?? 'Could not create team member'));
    } catch (e) {
      return ErrorResult(CacheFailure('Could not create team member: $e'));
    }
  }

  @override
  Future<Result<StaffInviteResult>> createInvite({
    required UserRole role,
    required Set<String> permissions,
  }) async {
    if (!_store.hasStore) {
      return const ErrorResult(CacheFailure('No store selected'));
    }
    if (role == UserRole.owner) {
      return const ErrorResult(ValidationFailure('Cannot invite as owner'));
    }
    try {
      final permMap = {for (final p in permissions) p: true};
      final created = await _invites.createInvite(
        storeId: _store.storeId,
        createdBy: _store.userId,
        role: role,
        permissions: permMap,
      );
      await AuditLogService.optional?.record(
        action: 'staff_invite_created',
        entityType: 'storeInvite',
        entityId: created.code,
        newValue: {'role': role.name},
      );
      return Success(
        StaffInviteResult(code: created.code, expiresAt: created.expiresAt, role: role),
      );
    } catch (e) {
      return ErrorResult(CacheFailure('Could not create invite: $e'));
    }
  }

  @override
  Future<Result<void>> updateStaff({
    required String userId,
    required UserRole role,
    required Set<String> permissions,
    required bool isActive,
  }) async {
    if (!_store.hasStore) {
      return const ErrorResult(CacheFailure('No store selected'));
    }
    try {
      final permMap = {for (final p in permissions) p: true};
      await _remote.updateStaff(
        userId: userId,
        role: role.name,
        permissions: permMap,
        isActive: isActive,
      );
      await AuditLogService.optional?.record(
        action: 'staff_updated',
        entityType: 'user',
        entityId: userId,
        newValue: {'role': role.name, 'isActive': isActive},
      );
      return const Success(null);
    } catch (e) {
      return ErrorResult(CacheFailure('Could not update user: $e'));
    }
  }
}
