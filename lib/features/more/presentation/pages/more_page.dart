import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/permissions/user_role.dart';
import 'package:gsma/features/auth/presentation/controllers/auth_controller.dart';
import 'package:gsma/routes/app_routes.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          Obx(() {
            final user = auth.user.value;
            if (user == null) return const SizedBox.shrink();
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user.displayName.isNotEmpty ? user.displayName : user.email),
              subtitle: Text('${user.role.displayName} · Store ${user.storeId}'),
            );
          }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.inventory_outlined),
            title: const Text('Products'),
            onTap: () => Get.toNamed(AppRoutes.products),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('Purchases'),
            onTap: () => Get.toNamed(AppRoutes.purchases),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Customers'),
            onTap: () => Get.toNamed(AppRoutes.customers),
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping_outlined),
            title: const Text('Suppliers'),
            onTap: () => Get.toNamed(AppRoutes.suppliers),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Expenses'),
            onTap: () => Get.toNamed(AppRoutes.expenses),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            onTap: () => Get.toNamed(AppRoutes.notifications),
          ),
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: const Text('Team'),
            onTap: () => Get.toNamed(AppRoutes.users),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Audit log'),
            onTap: () => Get.toNamed(AppRoutes.auditLog),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () => Get.toNamed(AppRoutes.settings),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: auth.signOut,
          ),
        ],
      ),
    );
  }
}
