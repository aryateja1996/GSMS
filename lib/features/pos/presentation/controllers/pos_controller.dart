import 'dart:async';

import 'package:get/get.dart';
import 'package:gsma/core/calculations/pos_line_calculator.dart';
import 'package:gsma/core/constants/app_constants.dart';
import 'package:gsma/core/constants/payment_methods.dart';
import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/pos/domain/entities/pos_cart_line.dart';
import 'package:gsma/features/pos/domain/usecases/complete_sale_usecase.dart';
import 'package:gsma/features/customers/domain/entities/customer.dart';
import 'package:gsma/features/customers/domain/repositories/customer_repository.dart';
import 'package:gsma/features/products/domain/entities/product.dart';
import 'package:gsma/features/products/domain/repositories/product_repository.dart';

class PosController extends GetxController {
  PosController(this._products, this._completeSale, this._customers);

  final ProductRepository _products;
  final CompleteSaleUseCase _completeSale;
  final CustomerRepository _customers;

  final RxList<Product> searchResults = <Product>[].obs;
  final RxList<PosCartLine> cart = <PosCartLine>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<PaymentMethod> paymentMethod = PaymentMethod.cash.obs;
  final RxList<Customer> customers = <Customer>[].obs;
  final Rxn<Customer> selectedCustomer = Rxn<Customer>();
  final RxBool isProcessing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString lastInvoice = ''.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    customers.assignAll(await _customers.listCustomers());
  }

  BillTotals get totals => PosLineCalculator.billTotals(
        lines: cart
            .map(
              (l) => (
                qty: l.quantity,
                rate: l.rate,
                lineDiscount: l.lineDiscount,
                taxRate: l.taxRate,
              ),
            )
            .toList(),
      );

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _debounce?.cancel();
    _debounce = Timer(AppConstants.searchDebounce, () => _runSearch());
  }

  Future<void> _runSearch() async {
    final q = searchQuery.value.trim();
    if (q.isEmpty) {
      searchResults.clear();
      return;
    }
    searchResults.assignAll(await _products.listProducts(query: q, limit: 30));
  }

  Future<void> addByBarcode(String barcode) async {
    final product = await _products.getByBarcode(barcode);
    if (product != null) {
      addProduct(product);
    } else {
      errorMessage.value = 'No product for barcode $barcode';
    }
  }

  void addProduct(Product product) {
    final existing = cart.indexWhere((c) => c.product.id == product.id);
    if (existing >= 0) {
      cart[existing].quantity += 1;
      cart.refresh();
    } else {
      cart.add(PosCartLine(product: product));
    }
    searchQuery.value = '';
    searchResults.clear();
  }

  void updateQuantity(int index, double qty) {
    if (qty <= 0) {
      cart.removeAt(index);
    } else {
      cart[index].quantity = qty;
      cart.refresh();
    }
  }

  void clearCart() => cart.clear();

  Future<bool> checkout() async {
    if (cart.isEmpty) return false;
    isProcessing.value = true;
    errorMessage.value = '';
    final result = await _completeSale(
      lines: cart.toList(),
      paymentMethod: paymentMethod.value,
      customerId: selectedCustomer.value?.id,
    );
    isProcessing.value = false;
    switch (result) {
      case Success(value: final sale):
        lastInvoice.value = sale.invoiceNumber;
        clearCart();
        selectedCustomer.value = null;
        Get.snackbar('Sale complete', 'Invoice ${sale.invoiceNumber}');
        return true;
      case ErrorResult(failure: final failure):
        errorMessage.value = failure.message;
        return false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
