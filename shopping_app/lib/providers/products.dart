import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/models/exceptions/http_exception.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [];
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://flutter-shopping-app-8ca69-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      _items = [];
      if (extractedData == null) {
        return;
      }

      url = Uri.parse(
          'https://flutter-shopping-app-8ca69-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
      final favoritesResponse = await http.get(url);
      final favoriteData = json.decode(favoritesResponse.body);

      extractedData.forEach((productId, productData) {
        _items.add(
          Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            imageUrl: productData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[productId] ?? false,
          ),
        );
      });
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return items.firstWhere((product) => product.id == id);
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://flutter-shopping-app-8ca69-default-rtdb.firebaseio.com/products.json?auth=$authToken');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );

      final newProduct = Product(
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        isFavorite: product.isFavorite,
        id: json.decode(response.body)['name'],
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product editedProduct) async {
    final prodIndex = _items.indexWhere((product) => product.id == id);

    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-shopping-app-8ca69-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      await http.patch(
        url,
        body: json.encode({
          'title': editedProduct.title,
          'description': editedProduct.description,
          'imageUrl': editedProduct.imageUrl,
          'price': editedProduct.price
        }),
      );
      _items[prodIndex] = editedProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://flutter-shopping-app-8ca69-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);

    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete product.');
      }
      existingProduct = null;
    } catch (error) {
      _items.insert(existingProductIndex, existingProduct);
    }
    notifyListeners();
  }
}
