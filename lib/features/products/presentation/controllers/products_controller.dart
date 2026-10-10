import 'package:get/get.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/products/domain/entities/category.dart';
import 'package:gsma/features/products/domain/entities/product.dart';
import 'package:gsma/features/products/domain/repositories/category_repository.dart';
import 'package:gsma/features/products/domain/repositories/product_repository.dart';

class ProductsController extends GetxController {
  ProductsController(this._products, this._categories);

  final ProductRepository _products;
  final CategoryRepository _categories;

  final RxList<Product> products = <Product>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxString searchQuery = ''.obs;
  final RxnString selectedCategoryId = RxnString();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _categories.ensureDefaultCategory();
      categories.assignAll(await _categories.listCategories());
      await refreshProducts();
    } catch (e) {
      errorMessage.value = 'Could not load products';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProducts() async {
    products.assignAll(
      await _products.listProducts(
        categoryId: selectedCategoryId.value,
        query: searchQuery.value.isEmpty ? null : searchQuery.value,
      ),
    );
  }

  void setCategoryFilter(String? categoryId) {
    selectedCategoryId.value = categoryId;
    refreshProducts();
  }

  void setSearch(String query) {
    searchQuery.value = query;
    refreshProducts();
  }

  Future<void> deactivate(String productId) async {
    final result = await _products.deactivateProduct(productId);
    switch (result) {
      case Success():
        await refreshProducts();
      case ErrorResult(failure: final failure):
        errorMessage.value = failure.message;
    }
  }
}
