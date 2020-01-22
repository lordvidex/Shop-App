import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class ProductProvider with ChangeNotifier {
  final String authToken;
  final String userId;
  ProductProvider(this.authToken, this.userId, this._items);
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product getProductById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }

  Future<void> updateProduct(String productId, Product product) async {
    final url =
        'https://flutter-shop-601f4.firebaseio.com/products/$productId.json?auth=$authToken';
    await http.patch(
      url,
      body: json.encode({
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
      }),
    );
    int prodIndex = _items.indexWhere((prod) => prod.id == productId);
    _items[prodIndex] = product;
    notifyListeners();
  }

  Future<void> fetchAndSetProducts([bool general = true]) async {
    final creatorFilter =
        general ? '' : '&orderBy="creatorId"&equalTo="$userId"';
    try {
      var url =
          'https://flutter-shop-601f4.firebaseio.com/products.json?auth=$authToken$creatorFilter';
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        throw HttpException('Couldn\'t fetch Products');
      }
      final loadedData = json.decode(response.body) as Map<String, dynamic>;
      if (loadedData == null) {
        return;
      }
      url =
          'https://flutter-shop-601f4.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(url);
      final Map<String, dynamic> favoriteData =
          json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      loadedData.forEach((prodId, prodData) {
        final prod = Product(
          id: prodId,
          title: prodData['title'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          description: prodData['description'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        );
        loadedProducts.add(prod);
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final url =
          'https://flutter-shop-601f4.firebaseio.com/products.json?auth=$authToken';
      var response = await http.post(
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
        price: product.price,
        title: product.title,
        description: product.description,
        id: json.decode(response.body)['name'],
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteProduct(String productId) async {
    //Optimistic deleting implemented here

    final url =
        'https://flutter-shop-601f4.firebaseio.com/products/$productId.json?auth=$authToken';
    final delprodId = _items.indexWhere((prod) => productId == prod.id);
    var deletedProduct = _items[delprodId];

    _items.removeWhere((prod) => prod.id == productId);
    notifyListeners();
    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        _items.insert(delprodId, deletedProduct);
        notifyListeners();
        throw HttpException('Error deleting product!');
      }
    } catch (error) {
      throw error;
    }
    deletedProduct = null;
  }
}
