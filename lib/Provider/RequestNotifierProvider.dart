import 'package:flutter/foundation.dart';

class RequestNotifierProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Add method to update requests list
  void updateRequests(List<Map<String, dynamic>> updatedRequests) {
    _requests = updatedRequests;
    notifyListeners();
  }

  // Existing implementation for requests list
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> get requests => _requests;

  void setRequests(List<Map<String, dynamic>> requests) {
    _requests = requests;
    notifyListeners();
  }
}
