import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/constants/app_constants.dart';
import 'package:gsma/core/constants/khata_transaction_type.dart';
import 'package:gsma/features/customers/domain/repositories/customer_repository.dart';
import 'package:gsma/features/khata/presentation/controllers/khata_controller.dart';

class KhataStatementPage extends StatefulWidget {
  const KhataStatementPage({super.key});

  @override
  State<KhataStatementPage> createState() => _KhataStatementPageState();
}

class _KhataStatementPageState extends State<KhataStatementPage> {
  late final String customerId;
  String _customerName = '';
  double _outstanding = 0;

  @override
  void initState() {
    super.initState();
    customerId = Get.parameters['customerId'] ?? '';
    _load();
  }

  Future<void> _load() async {
    final customers = Get.find<CustomerRepository>();
    final khata = Get.find<KhataController>();
    final c = await customers.getById(customerId);
    _outstanding = await khata.outstandingFor(customerId);
    await khata.loadStatement(customerId);
    setState(() => _customerName = c?.name ?? 'Customer');
  }

  Future<void> _paymentDialog() async {
    final amount = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Receive payment'),
        content: TextField(
          controller: amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true) {
      final khata = Get.find<KhataController>();
      final success = await khata.receivePayment(
        customerId: customerId,
        amount: double.tryParse(amount.text) ?? 0,
      );
      if (success) await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final khata = Get.find<KhataController>();
    return Scaffold(
      appBar: AppBar(title: Text('Khata — $_customerName')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _paymentDialog,
        icon: const Icon(Icons.payments),
        label: const Text('Payment'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Outstanding: ${AppConstants.defaultCurrencySymbol}${_outstanding.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: khata.statement.length,
                itemBuilder: (context, i) {
                  final t = khata.statement[i];
                  final sign = t.type == KhataTransactionType.payment ? '-' : '+';
                  return ListTile(
                    title: Text(
                      '${t.type.name} $sign${AppConstants.defaultCurrencySymbol}${t.amount.toStringAsFixed(2)}',
                    ),
                    subtitle: Text(t.description ?? ''),
                    trailing: Text('Bal ${t.balanceAfter.toStringAsFixed(0)}'),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
