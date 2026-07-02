import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String _errorMessage = "";
  bool _isLoggedIn = false;

  UserModel? get user         => _user;
  bool        get isLoading   => _isLoading;
  String      get errorMessage => _errorMessage;
  bool        get isLoggedIn  => _isLoggedIn;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // ─── User Login ───────────────────────────────────────────────────────
  // Sends email + password. Returns true on success, false on failure.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = "";

      final user = await _authService.login(
        email: email,
        password: password,
      );

      _user = user;
      _isLoggedIn = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(_friendlyError(e));
      return false;
    }
  }

  // ─── Admin Login ──────────────────────────────────────────────────────
  // Sends email + password to /auth/admin-login.
  // Returns true on success, false on failure.
  Future<bool> adminLogin({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = "";

      final user = await _authService.adminLogin(
        email: email,
        password: password,
      );

      _user = user;
      _isLoggedIn = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(_friendlyError(e));
      return false;
    }
  }

  // ─── Register ────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = "";

      final user = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      _user = user;
      _isLoggedIn = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(_friendlyError(e));
      return false;
    }
  }

  // ─── Auto Login (Splash screen) ──────────────────────────────────────
  // Restores session from SharedPreferences if the stored JWT is still valid.
  Future<bool> autoLogin() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      if (JwtDecoder.isExpired(token)) {
        await logout();
        return false;
      }

      final userString = await StorageService.getUser();
      if (userString == null) return false;

      _user = UserModel.fromJson(jsonDecode(userString));
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Logout ──────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  // ─── Helper: extract readable message from Dio / generic errors ──────
  String _friendlyError(Object e) {
    final msg = e.toString();
    // Dio wraps the server message inside DioException; strip the prefix.
    if (msg.contains("DioException")) {
      final start = msg.indexOf('"message"');
      if (start != -1) return msg.substring(start);
    }
    return msg;
  }
}