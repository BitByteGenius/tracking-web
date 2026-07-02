import 'package:dio/dio.dart';

import '../config/api_constants.dart';
import '../models/tracking_model.dart';
import 'api_service.dart';

class TrackingService {
  final Dio _dio = ApiService.instance.dio;

  // ─── Start Tracking ────────────────────────────────────────────────────
  // POST /api/tracking/start
  Future<TrackingModel> startTracking({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
    required double heading,
    required String place,
    required String city,
    required String state,
    required String country,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.trackingStart,
        data: {
          "latitude":  latitude,
          "longitude": longitude,
          "accuracy":  accuracy,
          "speed":     speed,
          "heading":   heading,
          "place":     place,
          "city":      city,
          "state":     state,
          "country":   country,
        },
      );
      return TrackingModel.fromJson(
        response.data["data"] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      // 409 = already checked in — treat as a known app state, not a crash.
      if (e.response?.statusCode == 409) {
        throw Exception("You are already checked in.");
      }
      throw Exception(
        e.response?.data?["message"] ?? "Unable to start tracking",
      );
    }
  }

  // ─── Update Location ───────────────────────────────────────────────────
  // PUT /api/tracking/update
  Future<TrackingModel> updateTracking({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
    required double heading,
    required String place,
    required String city,
    required String state,
    required String country,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.trackingUpdate,
        data: {
          "latitude":  latitude,
          "longitude": longitude,
          "accuracy":  accuracy,
          "speed":     speed,
          "heading":   heading,
          "place":     place,
          "city":      city,
          "state":     state,
          "country":   country,
        },
      );
      return TrackingModel.fromJson(
        response.data["data"] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? "Unable to update location",
      );
    }
  }

  // ─── Stop Tracking ─────────────────────────────────────────────────────
  // POST /api/tracking/stop
  Future<void> stopTracking() async {
    try {
      await _dio.post(ApiConstants.trackingStop);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? "Unable to stop tracking",
      );
    }
  }

  // ─── Get My Status (app-restart sync) ─────────────────────────────────
  // GET /api/tracking/status
  // Returns "Online" or "Offline" and the latest tracking doc (or null).
  // Called once after autoLogin so _isTracking always matches the DB state.
  Future<({String status, TrackingModel? tracking})> getMyStatus() async {
    try {
      final response = await _dio.get(ApiConstants.trackingStatus);
      final status = response.data["status"] as String? ?? "Offline";
      final data   = response.data["data"];
      return (
        status:   status,
        tracking: data != null
            ? TrackingModel.fromJson(data as Map<String, dynamic>)
            : null,
      );
    } on DioException catch (e) {
      // If the request fails (e.g. network error), assume Offline so the UI
      // stays usable rather than locking the user out.
      throw Exception(
        e.response?.data?["message"] ?? "Unable to fetch tracking status",
      );
    }
  }

  // ─── Get Live Users (Admin) ────────────────────────────────────────────
  // GET /api/tracking/live
  Future<List<TrackingModel>> getLiveUsers() async {
    try {
      final response = await _dio.get(ApiConstants.trackingLive);

      final List<dynamic> data = response.data["data"] as List<dynamic>;

      return data
          .map((e) => TrackingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ?? "Unable to fetch live users",
      );
    }
  }
}