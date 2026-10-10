import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/customers/domain/entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> listCustomers({String? query});
  Future<Customer?> getById(String id);
  Future<Result<Customer>> saveCustomer(Customer customer);
  Future<Result<void>> deactivateCustomer(String id);
}
