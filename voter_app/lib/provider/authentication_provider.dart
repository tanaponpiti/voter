import 'package:flutter/material.dart';
import 'package:voter_app/connector/authentication_connector.dart';
import 'package:voter_app/exception/invalid_login_exception.dart';
import 'package:voter_app/exception/token_not_found_exception.dart';
import 'package:voter_app/model/user.dart';
import 'package:voter_app/storage/storage_service.dart';

class AuthenticationProvider with ChangeNotifier {
  final StorageService storageService;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  User? _userInfo;

  User? get userInfo => _userInfo;

  AuthenticationProvider({required this.storageService});

  Future<String> getToken() async {
    final token = await storageService.read("token");
    if (token != null) {
      return token;
    } else {
      throw TokenNotFoundException("Token not found");
    }
  }

  Future<bool> checkLoggedInStatus() async {
    final userInfo = await reloadUserInfo();
    if (userInfo != null) {
      _isLoggedIn = true;
      notifyListeners();
    }
    return _isLoggedIn;
  }

  Future<void> login(String username, String password) async {
    final token = await loginUser(username, password);
    await storageService.write("token", token);
    _isLoggedIn = true;
    await reloadUserInfo();
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      await logoutUser(token);
    } catch (_) {
      //Do nothing when there is no token or cannot remove token from server
    } finally {
      await storageService.delete("token");
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  Future<User?> reloadUserInfo() async {
    try {
      final token = await getToken();
      final user = await getUserInfo(token);
      _userInfo = user;
    } on TokenNotFoundException catch (_) {
      _userInfo = null;
      _isLoggedIn = false;
    } on UnauthorizedException catch (_) {
      _userInfo = null;
      logout();
    }
    notifyListeners();
    return _userInfo;
  }
}
