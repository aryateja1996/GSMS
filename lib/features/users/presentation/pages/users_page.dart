import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/permissions/app_permissions.dart';
import 'package:gsma/core/permissions/user_role.dart';
import 'package:gsma/features/auth/domain/entities/app_user.dart';
import 'package:gsma/features/auth/presentation/controllers/auth_controller.dart';
import 'package:gsma/features/users/presentation/controllers/users_controller.dart';
import 'package:gsma/routes/app_routes.dart';

class UsersPage extends GetView<UsersController> {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      floatingActionButton: Obx(() {
        final canManage =
            auth.user.value?.hasPermission(AppPermissions.canManageUsers) ?? false;
        if (!canManage) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: () => Get.toNamed(AppRoutes.addStaff)?.then((_) => controller.load()),
          child: const Icon(Icons.person_add),
        );
      }),
      appBar: AppBar(
        title: const Text('Team'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: controller.load),
        ],
      ),
      body: Obx(() {
        final loading = controller.isLoading.value;
        final error = controller.errorMessage.value;
        final team = controller.items;
        final canManage =
            auth.user.value?.hasPermission(AppPermissions.canManageUsers) ?? false;

        if (loading && team.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (error.isNotEmpty && team.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(error, textAlign: TextAlign.center),
            ),
          );
        }
        if (team.isEmpty) {
          return Center(
            child: Text(
              canManage
                  ? 'No team members yet. Tap + to add someone.'
                  : 'No team members to show.',
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView(
          children: [
            ...team.map(
              (u) => ListTile(
                title: Text(u.displayName.isNotEmpty ? u.displayName : u.email),
                subtitle: Text('${u.role.displayName} · ${u.isActive ? 'Active' : 'Disabled'}'),
                trailing: canManage ? const Icon(Icons.edit) : null,
                onTap: canManage ? () => _edit(context, u) : null,
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _edit(BuildContext context, AppUser user) async {
    var role = user.role;
    var active = user.isActive;
    final perms = user.permissions.toSet();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Edit ${user.email}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<UserRole>(
                  initialValue: role,
                  items: UserRole.values
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.displayName)))
                      .toList(),
                  onChanged: (v) => setState(() => role = v ?? role),
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
                SwitchListTile(
                  title: const Text('Active'),
                  value: active,
                  onChanged: (v) => setState(() => active = v),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Permissions'),
                ),
                ...controller.allPermissionKeys().map(
                      (p) => CheckboxListTile(
                        dense: true,
                        title: Text(p, style: Theme.of(ctx).textTheme.bodySmall),
                        value: perms.contains(p),
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              perms.add(p);
                            } else {
                              perms.remove(p);
                            }
                          });
                        },
                      ),
                    ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (ok == true) {
      await controller.updateUser(
        user: user,
        role: role,
        permissions: perms,
        isActive: active,
      );
    }
  }
}
