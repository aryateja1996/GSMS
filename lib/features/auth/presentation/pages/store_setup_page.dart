import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/constants/app_constants.dart';
import 'package:gsma/core/validators/form_validators.dart';
import 'package:gsma/features/auth/presentation/controllers/auth_controller.dart';
import 'package:gsma/routes/app_routes.dart';

class StoreSetupPage extends GetView<AuthController> {
  const StoreSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final storeName = TextEditingController();
    final storeAddress = TextEditingController();
    final storePhone = TextEditingController();
    final ownerName = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    final confirmPassword = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Set up your store')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'First-time setup',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your store and owner account. This is only available once '
                  'before any store exists in ${AppConstants.appName}.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                Text('Store', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextFormField(
                  controller: storeName,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Store name *',
                    prefixIcon: Icon(Icons.store),
                  ),
                  validator: (v) => FormValidators.required(v, field: 'Store name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: storeAddress,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: storePhone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: FormValidators.phone,
                ),
                const SizedBox(height: 24),
                Text('Owner account', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ownerName,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Your name *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => FormValidators.required(v, field: 'Your name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => FormValidators.required(v, field: 'Email'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password *',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: FormValidators.password,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm password *',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) => FormValidators.required(v, field: 'Confirm password'),
                ),
                const SizedBox(height: 24),
                Obx(() {
                  final loading = controller.uiState.value == AuthUiState.loading;
                  return FilledButton(
                    onPressed: loading
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            if (password.text != confirmPassword.text) {
                              controller.errorMessage.value =
                                  'Passwords do not match';
                              return;
                            }
                            await controller.registerFirstOwner(
                              storeName: storeName.text,
                              storeAddress: storeAddress.text,
                              storePhone: storePhone.text,
                              ownerName: ownerName.text,
                              email: email.text,
                              password: password.text,
                              confirmPassword: confirmPassword.text,
                            );
                          },
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create store & sign in'),
                  );
                }),
                Obx(() {
                  final err = controller.errorMessage.value;
                  if (err.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      err,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.offNamed(AppRoutes.login),
                  child: const Text('Already have an account? Sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
