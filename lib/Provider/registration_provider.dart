import 'package:flutter/material.dart';

class RegistrationProvider extends ChangeNotifier {
  String? _selectedRole;
  String? _selectedSubRole;
  bool _registrationSuccessful=false;

  final List<String> roles = ['Employee', 'Other'];
  final List<String> employeeSubRoles = ['Pickup Staff', 'Compost Facility Staff'];

  String? get selectedRole => _selectedRole;
  String? get selectedSubRole => _selectedSubRole;
  bool get registrationSuccessful=> _registrationSuccessful;

  void setSelectedRole(String? role) {
    _selectedRole = role;
    _selectedSubRole = null;
    notifyListeners();
  }

  void setSelectedSubRole(String? subRole) {
    _selectedSubRole = subRole;
    notifyListeners();
  }
  void setRegistrationSuccessful(bool successful){
    _registrationSuccessful=successful;
    notifyListeners();
  }
}