import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.imageUrl,
    @required this.title,
    @required this.description,
    @required this.price,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final url =
        'https://flutter-shop-601f4.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    var prevFavStatus = isFavorite;

    //Change the UI
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(
        url,
        body: json.encode(isFavorite),
      );
      if (response.statusCode >= 400) {
        throw HttpException('Error changing Favorite Status');
      }
    } catch (error) {
      isFavorite = prevFavStatus;
      notifyListeners();
      throw error;
    }
    prevFavStatus = null;
  }
}
