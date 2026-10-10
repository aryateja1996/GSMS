import 'package:gsma/features/products/domain/entities/product.dart';

class PosCartLine {
  PosCartLine({
    required this.product,
    this.quantity = 1,
    this.lineDiscount = 0,
  });

  final Product product;
  double quantity;
  double lineDiscount;

  double get rate => product.sellingPrice;
  double get taxRate => product.taxRate;
}
