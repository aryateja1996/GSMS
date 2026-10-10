import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/products/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> listProducts({
    String? categoryId,
    String? query,
    int limit,
    int offset,
  });

  Future<Product?> getById(String id);
  Future<Product?> getByBarcode(String barcode);

  Future<Result<Product>> saveProduct(Product product);
  Future<Result<void>> deactivateProduct(String id);
}
