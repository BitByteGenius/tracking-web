import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';

/// Singleton Dio client used by all services.
///
/// Automatically injects the Bearer token from SharedPreferences
/// on every request if one is stored.
class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  late final Dio dio =
      Dio(
          BaseOptions(
            // Pulled from ApiConstants — change the URL there to switch environments.
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: ApiConstants.timeout,
            receiveTimeout: ApiConstants.timeout,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString("token");

              if (token != null && token.isNotEmpty) {
                options.headers["Authorization"] = "Bearer $token";
              }

              handler.next(options);
            },
            onError: (DioException e, handler) {
              final statusCode = e.response?.statusCode;

              // 409 = "already checked in" — this is a normal application-level
              // response handled gracefully by TrackingService. Do not log it
              // as an error so the debug console stays clean.
              //
              // Log everything else (4xx unexpected, 5xx server errors, network
              // failures) so real problems are still visible during development.
              const silentCodes = {409};

              if (kDebugMode && !silentCodes.contains(statusCode)) {
                // ignore: avoid_print
                print("[ApiService] Error: $statusCode ${e.message}");
              }

              handler.next(e);
            },
          ),
        );
}
