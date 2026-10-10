import 'package:get/get.dart';
import 'package:gsma/core/constants/stock_movement_type.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/inventory/domain/entities/stock_movement.dart';
import 'package:gsma/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:gsma/features/products/domain/repositories/product_repository.dart';

class InventoryController extends GetxController {
  InventoryController(this._inventory, this._products);

  final InventoryRepository _inventory;
  final ProductRepository _products;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxList<ProductStockSummary> stockList = <ProductStockSummary>[].obs;
  final RxList<StockMovement> recentMovements = <StockMovement>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      stockList.assignAll(
        await _inventory.listStockSummaries(
          query: searchQuery.value.isEmpty ? null : searchQuery.value,
        ),
      );
      recentMovements.assignAll(await _inventory.recentMovements());
    } catch (e) {
      errorMessage.value = 'Could not load inventory';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> stockIn({
    required String productId,
    required double quantity,
    String? reason,
  }) async {
    final product = await _products.getById(productId);
    if (product == null) return false;
    final result = await _inventory.recordMovement(
      productId: productId,
      type: StockMovementType.adjustmentIn,
      quantity: quantity,
      unit: product.baseUnit,
      reason: reason ?? 'Manual stock in',
    );
    switch (result) {
      case Success():
        await load();
        return true;
      case ErrorResult(failure: final failure):
        errorMessage.value = failure.message;
        return false;
    }
  }
}
