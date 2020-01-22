import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_token != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _expiryDate != null) {
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
      autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final storedData = json.encode({
        'token': _token,
        'expiryDate': _expiryDate.toIso8601String(),
        'userId': _userId,
      });
      prefs.setString('userData', storedData);
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

  Future<void> logout() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  void autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final storedData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final storedTime = DateTime.parse(storedData['expiryDate']);
    if (storedTime.isBefore(DateTime.now())) {
      return false;
    }
    _token = storedData['token'];
    _expiryDate = storedTime;
    _userId = storedData['userId'];
    notifyListeners();
    autoLogout();
    return true;
  }
}
