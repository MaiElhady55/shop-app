import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  String authToken = '';
  String userId = '';

  getData(String authTok, String uId, List<Product> products) {
    authToken = authTok;
    userId = uId;
    _items = products;
    notifyListeners();
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoritesItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts({bool filterByUser = false}) async {
    String filteredString =
        filterByUser ? 'orderaBy="creatorId"&equelTo"$userId"' : '';

    var url =
        'https://shop-app-34843-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filteredString';
    try {
      final res = await http.get(Uri.parse(url));
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          'https://shop-app-34843-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favRes = await http.get(Uri.parse(url));
      final favData = json.decode(favRes.body);

      List<Product> loadeProducts = [];
      extractedData.forEach((prodId, prodDta) {
        loadeProducts.add(Product(
            id: prodId,
            title: prodDta['title'],
            description: prodDta['description'],
            price: prodDta['price'],
            isFavorite: favData == null ? false : favData[prodId] ?? false,
            imageUrl: prodDta['imageUrl']));
      });
      _items = loadeProducts;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://shop-app-34843-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final res = await http.post(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId
          }));
      final newProduct = Product(
          id: json.decode(res.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);

      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateProduct(String id, Product newproduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://shop-app-34843-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(Uri.parse(url),
          body: json.encode({
            'title': newproduct.title,
            'description': newproduct.description,
            'imageUrl': newproduct.imageUrl,
            'price': newproduct.price,
          }));
      _items[prodIndex] = newproduct;
      notifyListeners();
    } else {
      print("******");
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://shop-app-34843-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prodId) => prodId.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final res = await http.delete(Uri.parse(url));
    if (res.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
