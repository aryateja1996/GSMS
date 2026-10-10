import 'package:get/get.dart';
import 'package:gsma/core/constants/unit_types.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/products/domain/entities/category.dart';
import 'package:gsma/features/products/domain/entities/product.dart';
import 'package:gsma/features/products/domain/repositories/category_repository.dart';
import 'package:gsma/features/products/domain/repositories/product_repository.dart';

class ProductFormController extends GetxController {
  ProductFormController(this._products, this._categories);

  final ProductRepository _products;
  final CategoryRepository _categories;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Category> categories = <Category>[].obs;
  final Rxn<Product> editing = Rxn<Product>();

  String? productIdArg;

  @override
  void onInit() {
    super.onInit();
    productIdArg = Get.parameters['id'];
    _init();
  }

  Future<void> _init() async {
    isLoading.value = true;
    await _categories.ensureDefaultCategory();
    categories.assignAll(await _categories.listCategories());
    if (productIdArg != null && productIdArg!.isNotEmpty) {
      editing.value = await _products.getById(productIdArg!);
    }
    isLoading.value = false;
  }

  Future<bool> save({
    required String name,
    String? barcode,
    String? sku,
    required String categoryId,
    required UnitType unitType,
    required double purchasePrice,
    required double sellingPrice,
    required double mrp,
    required double taxRate,
    required double minimumStock,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    final now = DateTime.now();
    final existing = editing.value;
    final product = Product(
      id: existing?.id ?? '',
      storeId: existing?.storeId ?? '',
      name: name.trim(),
      barcode: barcode?.trim().isEmpty == true ? null : barcode?.trim(),
      sku: sku?.trim().isEmpty == true ? null : sku?.trim(),
      categoryId: categoryId,
      unitType: unitType,
      baseUnit: unitType.label,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      mrp: mrp,
      taxRate: taxRate,
      minimumStock: minimumStock,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      isActive: true,
    );

    final result = await _products.saveProduct(product);
    isLoading.value = false;
    switch (result) {
      case Success():
        return true;
      case ErrorResult(failure: final failure):
        errorMessage.value = failure.message;
        return false;
    }
  }
}
