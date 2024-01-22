import 'package:flutter/material.dart';
import 'package:voter_app/storage/storage_service.dart';

class AuthenticationProvider with ChangeNotifier {
  final StorageService storageService;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  AuthenticationProvider({required this.storageService});

  Future<String?> getToken() async {
    return await storageService.read("token");
  }

  Future<bool> checkLoggedInStatus() async {
    String? token = await storageService.read("token");
    if (token != null) {
      _isLoggedIn = true;
      notifyListeners();
    }
    return _isLoggedIn;
  }

  Future<void> login(String token) async {
    await storageService.write("token", token);
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await storageService.delete("token");
    _isLoggedIn = false;
    notifyListeners();
  }
}
