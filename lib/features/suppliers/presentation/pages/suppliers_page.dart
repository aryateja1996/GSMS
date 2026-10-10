import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/constants/app_constants.dart';
import 'package:gsma/features/purchases/domain/repositories/purchase_repository.dart';
import 'package:gsma/features/suppliers/domain/entities/supplier.dart';
import 'package:gsma/features/suppliers/domain/repositories/supplier_repository.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  final _repo = Get.find<SupplierRepository>();
  final _purchases = Get.find<PurchaseRepository>();
  List<Supplier> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _items = await _repo.listSuppliers();
    setState(() => _loading = false);
  }

  Future<void> _addSupplier() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true || name.text.trim().isEmpty) return;
    final now = DateTime.now();
    await _repo.saveSupplier(
      Supplier(
        id: '',
        storeId: '',
        name: name.text,
        phone: phone.text,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSupplier,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final s = _items[i];
                return FutureBuilder<double>(
                  future: _purchases.getSupplierOutstanding(s.id),
                  builder: (context, snap) {
                    final due = snap.data ?? 0;
                    return ListTile(
                      title: Text(s.name),
                      subtitle: Text(s.phone ?? ''),
                      trailing: Text(
                        'Due ${AppConstants.defaultCurrencySymbol}${due.toStringAsFixed(0)}',
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
