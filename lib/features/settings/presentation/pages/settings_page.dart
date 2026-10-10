import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/features/settings/domain/entities/store_settings.dart';
import 'package:gsma/features/settings/presentation/controllers/settings_controller.dart';
import 'package:gsma/routes/app_routes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _controller = Get.find<SettingsController>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _gst = TextEditingController();
  final _currency = TextEditingController();
  final _invoicePrefix = TextEditingController();
  final _tax = TextEditingController();
  final _lowStock = TextEditingController();
  var _notifications = true;

  @override
  void initState() {
    super.initState();
    _bind(_controller.current.value);
    ever(_controller.current, (s) {
      if (s != null) _bind(s);
    });
  }

  void _bind(StoreSettings? s) {
    if (s == null) return;
    _name.text = s.storeName;
    _address.text = s.address;
    _phone.text = s.phone;
    _email.text = s.email;
    _gst.text = s.gstNumber;
    _currency.text = s.currencySymbol;
    _invoicePrefix.text = s.invoicePrefix;
    _tax.text = s.defaultTaxRate.toString();
    _lowStock.text = s.defaultLowStock.toString();
    _notifications = s.notificationsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.current.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Store', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Store name')),
            TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _gst, decoration: const InputDecoration(labelText: 'GST number')),
            const SizedBox(height: 16),
            Text('Billing', style: Theme.of(context).textTheme.titleMedium),
            TextField(controller: _currency, decoration: const InputDecoration(labelText: 'Currency symbol')),
            TextField(controller: _invoicePrefix, decoration: const InputDecoration(labelText: 'Invoice prefix')),
            TextField(
              controller: _tax,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Default tax %'),
            ),
            const SizedBox(height: 16),
            Text('Inventory', style: Theme.of(context).textTheme.titleMedium),
            TextField(
              controller: _lowStock,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Default low stock threshold'),
            ),
            SwitchListTile(
              title: const Text('In-app notifications'),
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Sync queue'),
              subtitle: const Text('View pending and failed uploads'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed(AppRoutes.syncQueue),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save settings')),
            if (_controller.errorMessage.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _controller.errorMessage.value,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        );
      }),
    );
  }

  Future<void> _save() async {
    final settings = StoreSettings(
      storeName: _name.text.trim(),
      address: _address.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      gstNumber: _gst.text.trim(),
      currencySymbol: _currency.text.trim().isEmpty ? '₹' : _currency.text.trim(),
      invoicePrefix: _invoicePrefix.text.trim().isEmpty ? 'INV' : _invoicePrefix.text.trim(),
      defaultTaxRate: double.tryParse(_tax.text) ?? 0,
      defaultLowStock: double.tryParse(_lowStock.text) ?? 5,
      notificationsEnabled: _notifications,
    );
    final ok = await _controller.save(settings);
    if (ok && mounted) {
      Get.snackbar('Saved', 'Store settings updated');
    }
  }
}
