import 'food_item.dart';

class CartItem {
  final String id;
  final FoodItem foodItem;
  int quantity;

  CartItem({
    required this.id,
    required this.foodItem,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodItem': foodItem.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    final quantityValue = map['quantity'];
    final quantity = quantityValue is int
        ? quantityValue
        : int.tryParse(quantityValue?.toString() ?? '1') ?? 1;

    return CartItem(
      id: map['id'] ?? '',
      foodItem: FoodItem.fromMap(Map<String, dynamic>.from(map['foodItem'] ?? {})),
      quantity: quantity,
    );
  }
}
