import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/constants/app_constants.dart';
import 'package:gsma/features/cash/presentation/controllers/cash_controller.dart';

class CashReconciliationPage extends GetView<CashController> {
  const CashReconciliationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cash reconciliation')),
      body: Obx(() {
        if (controller.isLoading.value && controller.summary.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final s = controller.summary.value;
        if (s == null) {
          return const Center(child: Text('No data'));
        }
        final sym = AppConstants.defaultCurrencySymbol;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: const Text('Business day'),
              trailing: TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDate: controller.selectedDay.value,
                  );
                  if (picked != null) controller.pickDay(picked);
                },
                child: Text(controller.selectedDay.value.toLocal().toString().split(' ').first),
              ),
            ),
            _row(context, 'Opening cash', s.openingCash, sym),
            _row(context, '+ Cash sales', s.cashSales, sym),
            _row(context, '+ Khata collections', s.khataCollections, sym),
            _row(context, '+ Other cash in', s.otherCashIn, sym),
            _row(context, '- Cash expenses', s.cashExpenses, sym, negative: true),
            const Divider(height: 32),
            _row(context, 'Expected closing', s.expectedClosingCash, sym, bold: true),
            if (s.actualClosingCash != null) ...[
              _row(context, 'Actual closing', s.actualClosingCash!, sym),
              _row(context, 'Variance', s.variance ?? 0, sym, bold: true),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => _amountDialog(context, 'Opening cash', controller.setOpening),
                  child: const Text('Set opening'),
                ),
                OutlinedButton(
                  onPressed: () => _amountDialog(
                    context,
                    'Other cash in',
                    (a) => controller.addOtherIn(a, description: 'Manual cash in'),
                  ),
                  child: const Text('Other cash in'),
                ),
                FilledButton(
                  onPressed: () => _amountDialog(context, 'Actual closing cash', controller.saveClosing),
                  child: const Text('Save closing count'),
                ),
              ],
            ),
            if (controller.errorMessage.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  controller.errorMessage.value,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    double value,
    String sym, {
    bool negative = false,
    bool bold = false,
  }) {
    final style = bold ? Theme.of(context).textTheme.titleMedium : null;
    final display = '${negative ? '-' : ''}$sym${value.abs().toStringAsFixed(2)}';
    return ListTile(
      title: Text(label, style: style),
      trailing: Text(display, style: style),
    );
  }

  Future<void> _amountDialog(
    BuildContext context,
    String title,
    Future<bool> Function(double) onSave,
  ) async {
    final amount = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
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
      await onSave(double.tryParse(amount.text) ?? 0);
    }
  }
}
