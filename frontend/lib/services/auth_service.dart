import 'package:dio/dio.dart';

import '../config/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final Dio _dio = ApiService.instance.dio;

  // ─── User Login ─────────────────────────────────────────────────────────
  // POST /api/auth/login
  // Body: { email, password }
  // Returns { success, user, token }
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {
        "email": email,
        "password": password,
      },
    );

    final token = response.data["token"] as String;
    final user = UserModel.fromJson(
      response.data["user"] as Map<String, dynamic>,
    );

    await StorageService.saveToken(token);
    await StorageService.saveUser(user.encode());

    return user;
  }

  // ─── Admin Login ────────────────────────────────────────────────────────
  // POST /api/auth/admin-login
  // Body: { email, password }
  // Returns { success, user: { _id:"admin", role:"admin", ... }, token }
  Future<UserModel> adminLogin({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.adminLogin,
      data: {
        "email": email,
        "password": password,
      },
    );

    final token = response.data["token"] as String;
    final user = UserModel.fromJson(
      response.data["user"] as Map<String, dynamic>,
    );

    await StorageService.saveToken(token);
    await StorageService.saveUser(user.encode());

    return user;
  }

  // ─── Register ───────────────────────────────────────────────────────────
  // POST /api/auth/register
  // Body: { name, email, phone, password }
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: {
        "name": name,
        "email": email,
        "phone": phone,
        "password": password,
      },
    );

    final token = response.data["token"] as String;
    final user = UserModel.fromJson(
      response.data["user"] as Map<String, dynamic>,
    );

    await StorageService.saveToken(token);
    await StorageService.saveUser(user.encode());

    return user;
  }

  // ─── Logout ─────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await StorageService.clear();
  }
}