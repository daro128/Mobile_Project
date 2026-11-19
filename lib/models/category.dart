enum CategoryType { income, expense }

class Category {
  final String id;
  final String name;
  final CategoryType type;

  Category({required this.id, required this.name, required this.type});
  
  Category updateCategory({
    String? name,
    CategoryType? type,
  }) => Category(
    id: id,
    name: name ?? this.name,
    type: type ?? this.type,
  );
}
