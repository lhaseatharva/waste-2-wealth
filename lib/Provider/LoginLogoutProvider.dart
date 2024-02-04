import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginLogoutProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
      // Handle logout error if needed
    }
  }
}
