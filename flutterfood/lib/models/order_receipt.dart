import 'cart_item.dart';

class OrderReceipt {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double discountAmount;
  final String? couponCode;
  final double totalAmount;
  final DateTime date;
  final String deliveryAddress;
  final double? latitude;
  final double? longitude;
  final String paymentMethod;

  OrderReceipt({
    required this.id,
    required this.items,
    required this.subtotal,
    this.discountAmount = 0.0,
    this.couponCode,
    required this.totalAmount,
    required this.date,
    required this.deliveryAddress,
    this.latitude,
    this.longitude,
    required this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'couponCode': couponCode,
      'totalAmount': totalAmount,
      'date': date.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'latitude': latitude,
      'longitude': longitude,
      'paymentMethod': paymentMethod,
    };
  }

  factory OrderReceipt.fromMap(Map<String, dynamic> map) {
    return OrderReceipt(
      id: map['id'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromMap(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      discountAmount: (map['discountAmount'] ?? 0.0).toDouble(),
      couponCode: map['couponCode'],
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      deliveryAddress: map['deliveryAddress'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
    );
  }
}
