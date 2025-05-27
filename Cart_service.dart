import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';

class CartService extends ChangeNotifier {
  List<CartItem> _items = [];
  List<OrderModel> _orders = [];
  static const String _cartKey = 'shopping_cart';
  static const String _ordersKey = 'order_history';
  final Uuid _uuid = const Uuid();

  List<CartItem> get items => _items;
  List<OrderModel> get orders => _orders;

  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);

  double get totalAmount => _items.fold(0.0, (total, item) => total + item.totalPrice);

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString(_cartKey);
      final ordersData = prefs.getString(_ordersKey);

      if (cartData != null) {
        final List<dynamic> jsonList = json.decode(cartData);
        _items = jsonList.map((json) => CartItem.fromJson(json)).toList();
      }

      if (ordersData != null) {
        final List<dynamic> jsonList = json.decode(ordersData);
        _orders = jsonList.map((json) => OrderModel.fromJson(json)).toList();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = json.encode(_items.map((item) => item.toJson()).toList());
      final ordersJson = json.encode(_orders.map((order) => order.toJson()).toList());
      
      await prefs.setString(_cartKey, cartJson);
      await prefs.setString(_ordersKey, ordersJson);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  void addToCart(Product product, {int quantity = 1}) {
    final existingItemIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingItemIndex >= 0) {
      _items[existingItemIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }

    saveCart();
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    saveCart();
    notifyListeners();
  }

  void updateQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      removeFromCart(product);
      return;
    }

    final existingItemIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingItemIndex >= 0) {
      _items[existingItemIndex].quantity = quantity;
      saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    saveCart();
    notifyListeners();
  }

  bool isInCart(Product product) {
    return _items.any((item) => item.product.id == product.id);
  }

  int getQuantity(Product product) {
    final item = _items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );
    return item.quantity;
  }

  Future<String> checkout() async {
    if (_items.isEmpty) return '';

    final orderId = _uuid.v4();
    final order = OrderModel(
      id: orderId,
      items: List.from(_items),
      total: totalAmount,
      date: DateTime.now(),
      status: 'En préparation',
    );

    _orders.insert(0, order);
    _items.clear();
    
    await saveCart();
    notifyListeners();
    
    return orderId;
  }

  String getFormattedPrice(double price) {
    return '${price.toStringAsFixed(2)} €';
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex >= 0) {
      _orders[orderIndex] = OrderModel(
        id: _orders[orderIndex].id,
        items: _orders[orderIndex].items,
        total: _orders[orderIndex].total,
        date: _orders[orderIndex].date,
        status: newStatus,
      );
      saveCart();
      notifyListeners();
    }
  }
}
