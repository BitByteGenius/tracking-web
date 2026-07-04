import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../models/tracking_model.dart';
import 'api_service.dart';
import 'dart:io';

class TrackingService {
  final Dio _dio = ApiService.instance.dio;

  // ─── Start Tracking ────────────────────────────────────────────────────
  // POST /api/tracking/start
  Future<TrackingModel> startTracking({
    required File photo,
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
    required double heading,
  }) async {
    try {
      final formData = FormData.fromMap({
        "photo": await MultipartFile.fromFile(
          photo.path,
          filename: "selfie.jpg",
        ),
        "latitude": latitude,
        "longitude": longitude,
        "accuracy": accuracy,
        "speed": speed,
        "heading": heading,
      });

      final response = await _dio.post(
        ApiConstants.trackingStart,
        data: formData,
      );

      return TrackingModel.fromJson(
        response.data["tracking"] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Unable to check in");
    }
  }

  // ─── Update Location ───────────────────────────────────────────────────
  Future<TrackingModel> updateTracking({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
    required double heading,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.trackingUpdate,
        data: {
          "latitude": latitude,
          "longitude": longitude,
          "accuracy": accuracy,
          "speed": speed,
          "heading": heading,
        },
      );

      return TrackingModel.fromJson(
        response.data["data"] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Unable to update location",
      );
    }
  }

  // ─── Stop Tracking ─────────────────────────────────────────────────────
  Future<void> stopTracking({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _dio.post(
        ApiConstants.trackingStop,
        data: {"latitude": latitude, "longitude": longitude},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Unable to check out");
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Get My Tracking Status
  // GET /tracking/status
  // ─────────────────────────────────────────────────────────────

  Future<({String status, TrackingModel? tracking})> getMyStatus() async {
    try {
      final response = await _dio.get(ApiConstants.trackingStatus);

      final String status = response.data["status"]?.toString() ?? "Offline";

      final trackingData = response.data["data"];

      return (
        status: status,
        tracking: trackingData == null
            ? null
            : TrackingModel.fromJson(trackingData as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Unable to fetch tracking status",
      );
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Get Live Users (Admin)
  // GET /tracking/live
  // ─────────────────────────────────────────────────────────────

  Future<List<TrackingModel>> getLiveUsers() async {
    try {
      final response = await _dio.get(ApiConstants.trackingLive);

      final List<dynamic> data = response.data["data"];

      return data
          .map((e) => TrackingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Unable to fetch live users",
      );
    }
  }
}
