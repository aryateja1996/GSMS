import 'package:get/get.dart';
import 'package:gsma/features/customers/domain/entities/customer.dart';
import 'package:gsma/features/customers/domain/repositories/customer_repository.dart';
import 'package:gsma/features/khata/domain/repositories/khata_repository.dart';

class CustomerWithBalance {
  CustomerWithBalance({required this.customer, required this.outstanding});

  final Customer customer;
  final double outstanding;
}

class CustomersController extends GetxController {
  CustomersController(this._customers, this._khata);

  final CustomerRepository _customers;
  final KhataRepository _khata;

  final RxList<CustomerWithBalance> items = <CustomerWithBalance>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
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
      final list = await _customers.listCustomers(
        query: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      final withBalance = <CustomerWithBalance>[];
      for (final c in list) {
        final outstanding = await _khata.getOutstanding(c.id);
        withBalance.add(CustomerWithBalance(customer: c, outstanding: outstanding));
      }
      items.assignAll(withBalance);
    } catch (e) {
      errorMessage.value = 'Could not load customers';
    } finally {
      isLoading.value = false;
    }
  }

  void search(String q) {
    searchQuery.value = q;
    load();
  }
}
