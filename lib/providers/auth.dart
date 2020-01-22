import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get isAuth {
    return token!=null;
  }
  String get userId{
    return _userId;
  }
  String get token{
    if(_token!=null&&_expiryDate.isAfter(DateTime.now())&& _expiryDate !=null){
      return _token;
    }
    return null;
  }
  Future<void> logUser(
      String email, String password, String urlFragment) async {
    //urlFragment is the difference between the login and signup functions
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlFragment?key=AIzaSyDNdklySVjjGrowxsWZFQF6F35WOf5s69M';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final jsonData = json.decode(response.body);
      if (jsonData['error'] != null) {
        throw HttpException(jsonData['error']['message']);
      }
      _token = jsonData['idToken'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(jsonData['expiresIn']),
        ),
      );
      _userId = jsonData['localId'];
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> login(String email, String password) async {
    return logUser(email, password, 'signInWithPassword');
  }

  Future<void> signup(String email, String password) async {
    return logUser(email, password, 'signUp');
  }
}
