import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/core/validators/form_validators.dart';
import 'package:gsma/features/customers/domain/entities/customer.dart';
import 'package:gsma/features/customers/domain/repositories/customer_repository.dart';

class CustomerFormPage extends StatefulWidget {
  const CustomerFormPage({super.key});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _repo = Get.find<CustomerRepository>();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _opening = TextEditingController(text: '0');
  final _creditLimit = TextEditingController(text: '0');
  bool _saving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add customer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (v) => FormValidators.required(v, field: 'Name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: FormValidators.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _opening,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Opening Khata balance',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _creditLimit,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Credit limit'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final now = DateTime.now();
    final result = await _repo.saveCustomer(
      Customer(
        id: '',
        storeId: '',
        name: _name.text,
        phone: _phone.text,
        email: _email.text,
        address: _address.text,
        openingBalance: double.tryParse(_opening.text) ?? 0,
        creditLimit: double.tryParse(_creditLimit.text) ?? 0,
        createdAt: now,
        updatedAt: now,
      ),
    );
    setState(() => _saving = false);
    switch (result) {
      case Success():
        Get.back(result: true);
      case ErrorResult(failure: final f):
        setState(() => _error = f.message);
    }
  }
}
