import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/suppliers/domain/entities/supplier.dart';

abstract class SupplierRepository {
  Future<List<Supplier>> listSuppliers({String? query});
  Future<Supplier?> getById(String id);
  Future<Result<Supplier>> saveSupplier(Supplier supplier);
}
