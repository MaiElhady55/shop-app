import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  String? _userId;
  DateTime? _expiryDate;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDdLQD6XibGJtanBMQ8YAzyiiFjZNxu7HA';
    try {
      final res = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final resData = await json.decode(res.body);
      if (resData['error'] != null) {
        throw HttpException(resData['error']['message']);
      }
      _token = resData['idToken'];
      _userId = resData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(resData['expiresIn'])));
      _autologout();
      notifyListeners();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> login(
    String email,
    String password,
  ) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> signUp(
    String email,
    String password,
  ) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<bool> tryAutoLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;
    final extractedData =
        json.decode(prefs.getString('userData')!) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedData['expiryDate']as String);
    if (expiryDate.isBefore(DateTime.now())) return false;

    _token = extractedData['token']as String;
    _userId = extractedData['userId']as String;
    _expiryDate = expiryDate;

    notifyListeners();
    _autologout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<void> _autologout() async {
    if (_authTimer != null) {
      _authTimer!.cancel();
    } else {
      final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
      _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
    }
  }
}

