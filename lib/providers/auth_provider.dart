import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final String _defaultEmail = 'admin@gmail.com';
  final String _defaultPassword = '123456';

  bool _loggedIn = false;
  bool get isLoggedIn => _loggedIn;

  String get defaultEmail => _defaultEmail;
  String get defaultPassword => _defaultPassword;

  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Always reset state before attempting login
    _loggedIn = false;

    if (email.isEmpty || password.isEmpty) {
      notifyListeners();
      throw Exception('Email and password must not be empty.');
    }

    if (email == _defaultEmail && password == _defaultPassword) {
      _loggedIn = true;
      notifyListeners();
      return;
    }

    notifyListeners();
    throw Exception('Invalid email or password.');
  }

  void logout() {
    _loggedIn = false;
    notifyListeners();
  }
}
