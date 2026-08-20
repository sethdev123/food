import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';
import 'package:uuid/uuid.dart';

class CartProvider with ChangeNotifier {
  static const Map<String, double> _couponRates = {
    'FOODIE20': 0.20,
    'MEMBER20': 0.20,
    'PREMIUM40': 0.40,
    'HALF50': 0.50,
    'SAVE70': 0.70,
    'FREE_SHIP': 0.00,
  };

  Map<String, double> get availableCoupons => {..._couponRates};

  Map<String, CartItem> _items = {};
  String _selectedCouponCode = '';

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  String get selectedCouponCode => _selectedCouponCode;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.foodItem.price * cartItem.quantity;
    });
    return total;
  }

  double get discountAmount {
    final rate = _couponRates[_selectedCouponCode] ?? 0.0;
    return totalAmount * rate;
  }

  double get totalAfterDiscount => (totalAmount - discountAmount).clamp(0.0, double.infinity);

  bool applyCoupon(String code) {
    final normalized = code.toUpperCase().trim();
    if (!_couponRates.containsKey(normalized)) {
      _selectedCouponCode = '';
      notifyListeners();
      return false;
    }
    _selectedCouponCode = normalized;
    notifyListeners();
    return true;
  }

  void clearCoupon() {
    if (_selectedCouponCode.isNotEmpty) {
      _selectedCouponCode = '';
      notifyListeners();
    }
  }

  void addItem(FoodItem foodItem) {
    if (_items.containsKey(foodItem.id)) {
      _items.update(
        foodItem.id,
        (existing) => CartItem(
          id: existing.id,
          foodItem: existing.foodItem,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        foodItem.id,
        () => CartItem(
          id: const Uuid().v4(),
          foodItem: foodItem,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeSingleItem(String foodId) {
    if (!_items.containsKey(foodId)) return;
    if (_items[foodId]!.quantity > 1) {
      _items.update(
        foodId,
        (existing) => CartItem(
          id: existing.id,
          foodItem: existing.foodItem,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(foodId);
    }
    notifyListeners();
  }

  void removeItem(String foodId) {
    _items.remove(foodId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
