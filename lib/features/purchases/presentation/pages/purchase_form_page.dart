import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/products/domain/entities/product.dart';
import 'package:gsma/features/products/domain/repositories/product_repository.dart';
import 'package:gsma/features/purchases/domain/repositories/purchase_repository.dart';
import 'package:gsma/features/suppliers/domain/entities/supplier.dart';
import 'package:gsma/features/suppliers/domain/repositories/supplier_repository.dart';

class _DraftLine {
  _DraftLine({required this.product, required this.qty, required this.rate});

  final Product product;
  double qty;
  double rate;
}

class PurchaseFormPage extends StatefulWidget {
  const PurchaseFormPage({super.key});

  @override
  State<PurchaseFormPage> createState() => _PurchaseFormPageState();
}

class _PurchaseFormPageState extends State<PurchaseFormPage> {
  final _suppliers = Get.find<SupplierRepository>();
  final _products = Get.find<ProductRepository>();
  final _purchases = Get.find<PurchaseRepository>();

  String? _supplierId;
  final _invoice = TextEditingController();
  final _paid = TextEditingController(text: '0');
  final _lines = <_DraftLine>[];
  var _suppliersList = <Supplier>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _suppliersList = await _suppliers.listSuppliers();
    setState(() => _loading = false);
  }

  Future<void> _addProduct() async {
    final picked = await showDialog<Product>(
      context: context,
      builder: (ctx) => _ProductPicker(products: _products),
    );
    if (picked == null) return;
    setState(() {
      _lines.add(
        _DraftLine(product: picked, qty: 1, rate: picked.purchasePrice),
      );
    });
  }

  Future<void> _save() async {
    if (_supplierId == null || _invoice.text.trim().isEmpty || _lines.isEmpty) {
      setState(() => _error = 'Supplier, invoice, and lines required');
      return;
    }
    final result = await _purchases.createPurchase(
      CreatePurchaseInput(
        supplierId: _supplierId!,
        invoiceNumber: _invoice.text,
        paidAmount: double.tryParse(_paid.text) ?? 0,
        lines: _lines
            .map(
              (l) => CreatePurchaseLineInput(
                productId: l.product.id,
                quantity: l.qty,
                rate: l.rate,
              ),
            )
            .toList(),
      ),
    );
    switch (result) {
      case Success():
        Get.back(result: true);
      case ErrorResult(failure: final f):
        setState(() => _error = f.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('New purchase')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Supplier *'),
            items: _suppliersList
                .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                .toList(),
            onChanged: (v) => setState(() => _supplierId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _invoice,
            decoration: const InputDecoration(labelText: 'Supplier invoice # *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _paid,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Paid now'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Items', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: _addProduct,
                icon: const Icon(Icons.add),
                label: const Text('Add product'),
              ),
            ],
          ),
          ..._lines.map(
            (l) => ListTile(
              title: Text(l.product.name),
              subtitle: Text('Qty ${l.qty} @ ${l.rate}'),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Save purchase')),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
        ],
      ),
    );
  }
}

class _ProductPicker extends StatefulWidget {
  const _ProductPicker({required this.products});

  final ProductRepository products;

  @override
  State<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends State<_ProductPicker> {
  List<Product> _results = [];
  bool _loading = false;

  Future<void> _search(String q) async {
    setState(() => _loading = true);
    _results = await widget.products.listProducts(query: q, limit: 30);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select product'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(hintText: 'Search'),
              onChanged: _search,
            ),
            if (_loading) const LinearProgressIndicator(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(_results[i].name),
                  onTap: () => Navigator.pop(context, _results[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
