import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, CartItem) {
      total += CartItem.price * CartItem.quantity;
    });
    return total;
  }

  void addItem(String ProductId, double price, String title) {
    if (_items.containsKey(ProductId)) {
      _items.update(
          ProductId,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              quantity: existingCartItem.quantity + 1,
              price: existingCartItem.price));
    } else {
      _items.putIfAbsent(
          ProductId,
          () => CartItem(
              id: DateTime.now().toString(),
              title: title,
              quantity: 1,
              price: price));
    }
    notifyListeners();
  }

  void removeItem(String ProductId) {
    _items.remove(ProductId);
    notifyListeners();
  }

  void removeSingleItem(String ProductId) {
    if (!_items.containsKey(ProductId)) {
      return;
    } else {
      if (_items[ProductId]!.quantity > 1) {
        _items.update(
            ProductId,
            (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                quantity: existingCartItem.quantity - 1,
                price: existingCartItem.price));
      } else {
        _items.remove(ProductId);
      }
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
