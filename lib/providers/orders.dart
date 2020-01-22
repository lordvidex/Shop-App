import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final String authToken;
  final String userId;

  Orders(this.authToken,this.userId, this._items);
  List<OrderItem> _items = [];

  List<OrderItem> get items {
    return [..._items];
  }

  Future<void> fetchAndSetOrders() async {
    final url = 'https://flutter-shop-601f4.firebaseio.com/orders/$userId.json?auth=$authToken';
    //add try and catch errors
    try {
      final response = await http.get(url);
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData == null) {
        return;
      }
      List<OrderItem> loadedOrders = [];
      responseData.forEach(
        (orderId, orderData) => loadedOrders.add(
          OrderItem(
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (cartI) => CartItem(
                    id: cartI['id'],
                    price: cartI['price'],
                    quantity: cartI['quantity'],
                    title: cartI['title'],
                  ),
                )
                .toList() as List<CartItem>,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            id: orderId,
          ),
        ),
      );
      _items = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      //
    }
  }

  Future<void> addOrder({List<CartItem> cartProducts, double total}) async {
    final timeStamp = DateTime.now();
    final url = 'https://flutter-shop-601f4.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((cartI) => {
                    'id': cartI.id,
                    'price': cartI.price,
                    'quantity': cartI.quantity,
                    'title': cartI.title,
                  })
              .toList(),
        }),
      );
      _items.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          dateTime: timeStamp,
          products: cartProducts,
        ),
      );
      notifyListeners();
    } catch (error) {
      //.. handle error gracefully
    }
  }
}
