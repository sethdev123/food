class FoodItem {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String category;
  bool isFavorite;

  FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.isFavorite = false,
  });

  FoodItem copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    String? category,
    bool? isFavorite,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'isFavorite': isFavorite,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}
