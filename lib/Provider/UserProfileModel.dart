import 'package:flutter/material.dart';

class UserProfileModel extends ChangeNotifier {
  String? name;
  String? email;
  String? contactNumber;

  void updateUserProfile({
    required String newName,
    required String newEmail,
    required String newContactNumber,
  }) {
    name = newName;
    email = newEmail;
    contactNumber = newContactNumber;
    notifyListeners();
  }
}
