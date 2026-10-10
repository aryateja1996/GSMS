import 'package:get/get.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/purchases/domain/entities/purchase.dart';
import 'package:gsma/features/purchases/domain/repositories/purchase_repository.dart';

class PurchasesController extends GetxController {
  PurchasesController(this._purchases);

  final PurchaseRepository _purchases;

  final RxList<Purchase> items = <Purchase>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      items.assignAll(await _purchases.listPurchases());
    } catch (e) {
      errorMessage.value = 'Could not load purchases';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> payDue(String purchaseId, double amount) async {
    final result = await _purchases.recordSupplierPayment(
      purchaseId: purchaseId,
      amount: amount,
    );
    switch (result) {
      case Success():
        await load();
        return true;
      case ErrorResult(failure: final f):
        errorMessage.value = f.message;
        return false;
    }
  }
}
