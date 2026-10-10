import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/validators/form_validators.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/auth/domain/usecases/join_store_with_invite_usecase.dart';
import 'package:gsma/features/auth/presentation/controllers/auth_controller.dart';
import 'package:gsma/routes/app_routes.dart';

class JoinStorePage extends StatefulWidget {
  const JoinStorePage({super.key});

  @override
  State<JoinStorePage> createState() => _JoinStorePageState();
}

class _JoinStorePageState extends State<JoinStorePage> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final useCase = Get.find<JoinStoreWithInviteUseCase>();
    final result = await useCase(
      JoinStoreWithInviteInput(
        inviteCode: _code.text,
        displayName: _name.text,
        email: _email.text,
        password: _password.text,
      ),
    );
    setState(() => _loading = false);
    switch (result) {
      case Success():
        await Get.find<AuthController>().refreshSession();
        Get.offAllNamed(AppRoutes.mainShell);
      case ErrorResult(failure: final f):
        setState(() => _error = f.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join store')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Enter the invite code from your store owner, then create your login.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _code,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Invite code *',
                    hintText: '6 characters',
                  ),
                  validator: (v) => FormValidators.required(v, field: 'Invite code'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Your name *'),
                  validator: (v) => FormValidators.required(v, field: 'Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email *'),
                  validator: (v) => FormValidators.required(v, field: 'Email'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password *'),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Min 6 characters' : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create account & join'),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
        ],
      ),
    );
  }
}
