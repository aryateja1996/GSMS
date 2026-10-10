import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gsma/core/permissions/app_permissions.dart';
import 'package:gsma/core/permissions/user_role.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/users/domain/entities/create_staff_input.dart';
import 'package:gsma/features/users/presentation/controllers/users_controller.dart';

class AddStaffPage extends StatefulWidget {
  const AddStaffPage({super.key});

  @override
  State<AddStaffPage> createState() => _AddStaffPageState();
}

class _AddStaffPageState extends State<AddStaffPage> {
  final _controller = Get.find<UsersController>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _role = UserRole.cashier;
  final _perms = AppPermissions.defaultsForRole(UserRole.cashier).toSet();
  var _modeInvite = false;
  String? _error;
  String? _inviteCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add team member')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Create account')),
              ButtonSegment(value: true, label: Text('Invite code')),
            ],
            selected: {_modeInvite},
            onSelectionChanged: (s) => setState(() {
              _modeInvite = s.first;
              _inviteCode = null;
              _error = null;
            }),
          ),
          const SizedBox(height: 16),
          if (_inviteCode != null) ...[
            Card(
              child: ListTile(
                title: const Text('Share this code with your staff'),
                subtitle: SelectableText(
                  _inviteCode!,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _inviteCode!));
                    Get.snackbar('Copied', 'Invite code copied');
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'They open the app → Join store with invite code → create their login.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            OutlinedButton(onPressed: () => Get.back(), child: const Text('Done')),
          ] else ...[
            DropdownButtonFormField<UserRole>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: UserRole.values
                  .where((r) => r != UserRole.owner)
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.displayName)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _role = v;
                  _perms
                    ..clear()
                    ..addAll(AppPermissions.defaultsForRole(v));
                });
              },
            ),
            const SizedBox(height: 12),
            if (!_modeInvite) ...[
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Display name *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Temporary password *',
                  helperText: 'Share securely; staff can reset later',
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text('Permissions', style: Theme.of(context).textTheme.titleSmall),
            ..._controller.allPermissionKeys().map(
                  (p) => CheckboxListTile(
                    dense: true,
                    title: Text(p, style: Theme.of(context).textTheme.bodySmall),
                    value: _perms.contains(p),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _perms.add(p);
                        } else {
                          _perms.remove(p);
                        }
                      });
                    },
                  ),
                ),
            const SizedBox(height: 24),
            if (!_modeInvite)
              Text(
                'Requires Cloud Function deploy (firebase deploy --only functions). '
                'Use Invite code if functions are not deployed yet.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _save,
              child: Text(_modeInvite ? 'Generate invite code' : 'Create account'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _error = null);
    if (_modeInvite) {
      final result = await _controller.createInvite(role: _role, permissions: _perms);
      switch (result) {
        case Success(value: final invite):
          setState(() => _inviteCode = invite.code);
        case ErrorResult(failure: final f):
          setState(() => _error = f.message);
      }
      return;
    }

    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty || _password.text.length < 6) {
      setState(() => _error = 'Name, email, and password (6+) required');
      return;
    }

    final ok = await _controller.createStaff(
      CreateStaffInput(
        email: _email.text.trim(),
        password: _password.text,
        displayName: _name.text.trim(),
        role: _role,
        permissions: _perms,
      ),
    );
    if (ok && mounted) {
      Get.back(result: true);
      Get.snackbar('Team member added', 'Share the temporary password with ${_email.text.trim()}');
    } else {
      setState(() => _error = _controller.errorMessage.value);
    }
  }
}
