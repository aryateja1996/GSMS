import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/constants/expense_categories.dart';
import 'package:gsma/core/constants/payment_methods.dart';
import 'package:gsma/features/expenses/domain/repositories/expense_repository.dart';
import 'package:gsma/features/expenses/presentation/controllers/expenses_controller.dart';

class ExpenseFormPage extends StatefulWidget {
  const ExpenseFormPage({super.key});

  @override
  State<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  final _controller = Get.find<ExpensesController>();
  var _category = ExpenseCategories.miscellaneous;
  final _amount = TextEditingController();
  final _description = TextEditingController();
  var _payment = PaymentMethod.cash;
  var _date = DateTime.now();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add expense')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: ExpenseCategories.all
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount *'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PaymentMethod>(
            initialValue: _payment,
            decoration: const InputDecoration(labelText: 'Payment method'),
            items: PaymentMethod.values
                .where((p) => p != PaymentMethod.split && p != PaymentMethod.credit)
                .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                .toList(),
            onChanged: (v) => setState(() => _payment = v ?? _payment),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(_date.toLocal().toString().split(' ').first),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 1)),
                initialDate: _date,
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Save expense')),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    final ok = await _controller.save(
      SaveExpenseInput(
        category: _category,
        amount: amount,
        paymentMethod: _payment.name,
        description: _description.text.trim().isEmpty ? null : _description.text.trim(),
        date: _date,
      ),
    );
    if (ok && mounted) Get.back(result: true);
    if (!ok) setState(() => _error = _controller.errorMessage.value);
  }
}
