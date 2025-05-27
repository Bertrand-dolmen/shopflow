import 'cart_item.dart';

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime date;
  final String status;

  OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    this.status = 'En préparation',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((item) => item.toJson()).toList(),
        'total': total,
        'date': date.toIso8601String(),
        'status': status,
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'],
        items: (json['items'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList(),
        total: json['total'].toDouble(),
        date: DateTime.parse(json['date']),
        status: json['status'],
      );

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get statusIcon {
    switch (status) {
      case 'En préparation':
        return '📦';
      case 'Expédié':
        return '🚚';
      case 'Livré':
        return '✅';
      default:
        return '📋';
    }
  }
}
