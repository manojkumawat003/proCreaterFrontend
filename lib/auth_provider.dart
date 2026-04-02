import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == 'admin';
  ApiService get apiService => _apiService;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _apiService.login(email, password);
      if (res['token'] != null) {
        _user = User.fromJson(res['user']);
        _apiService.setToken(res['token']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signup(String name, String email, String password, String role) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _apiService.signup(name, email, password, role);
      if (res['token'] != null) {
        _user = User.fromJson(res['user']);
        _apiService.setToken(res['token']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Signup error: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _user = null;
    _apiService.setToken(null);
    notifyListeners();
  }
}
