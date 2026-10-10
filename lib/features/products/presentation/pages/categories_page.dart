import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsma/features/products/domain/entities/category.dart';
import 'package:gsma/features/products/domain/repositories/category_repository.dart';
import 'package:gsma/core/utils/result.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final _repo = Get.find<CategoryRepository>();
  List<Category> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _items = await _repo.listCategories();
    setState(() => _loading = false);
  }

  Future<void> _addCategory() async {
    final nameController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New category'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (ok != true || nameController.text.trim().isEmpty) return;
    final result = await _repo.saveCategory(
      Category(
        id: '',
        storeId: '',
        name: nameController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    if (result case Success()) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) => ListTile(title: Text(_items[i].name)),
            ),
    );
  }
}
