class Expense {
  const Expense({
    required this.id,
    required this.storeId,
    required this.category,
    required this.amount,
    required this.paymentMethod,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.createdBy,
  });

  final String id;
  final String storeId;
  final String category;
  final double amount;
  final String paymentMethod;
  final String? description;
  final DateTime date;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense copyWithId({
    required String id,
    required String storeId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return Expense(
      id: id,
      storeId: storeId,
      category: category,
      amount: amount,
      paymentMethod: paymentMethod,
      description: description,
      date: date,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Expense copyWithUpdated(DateTime updatedAt) => Expense(
        id: id,
        storeId: storeId,
        category: category,
        amount: amount,
        paymentMethod: paymentMethod,
        description: description,
        date: date,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
