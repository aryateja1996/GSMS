import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/validators/form_validators.dart';
import 'package:gsma/features/auth/presentation/controllers/auth_controller.dart';

class ForgotPasswordPage extends GetView<AuthController> {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your account email. We will send a password reset link.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) => FormValidators.required(v, field: 'Email'),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final loading = controller.uiState.value == AuthUiState.loading;
                return FilledButton(
                  onPressed: loading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final ok = await controller.sendPasswordReset(
                            emailController.text,
                          );
                          if (ok && context.mounted) {
                            Get.back();
                            Get.snackbar(
                              'Email sent',
                              'Check your inbox for reset instructions.',
                            );
                          }
                        },
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send reset link'),
                );
              }),
              Obx(() {
                final err = controller.errorMessage.value;
                if (err.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    err,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
