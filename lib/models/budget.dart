class Budget {
  final String id;
  final String categoryId;
  final double limit;
  final int month;
  final int year;

  Budget({
    required this.id,
    required this.categoryId,
    required this.limit,
    required this.month,
    required this.year,
  });

  Budget updateBudget({
    String? categoryId,
    double? limit,
    int? month,
    int? year,
  }) => Budget(
    id: id,
    categoryId: categoryId ?? this.categoryId,
    limit: limit ?? this.limit,
    month: month ?? this.month,
    year: year ?? this.year,
  );
}
