import 'package:gsma/core/utils/result.dart';
import 'package:gsma/features/products/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> listCategories();
  Future<Result<Category>> saveCategory(Category category);
  Future<Result<Category>> ensureDefaultCategory();
}
