import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';

import '../core/constants/api_constants.dart';
import '../models/tracking_model.dart';
import 'api_service.dart';

class TrackingService {
  final Dio _dio = ApiService.instance.dio;

  // ─── Start Tracking (Check In) ──────────────────────────────────────────
  // POST /api/tracking/start
  // Sends multipart/form-data: photo (binary) + location fields.
  Future<TrackingModel> startTracking({
    required Uint8List photoBytes,
    required String filename,
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
    required double heading,
  }) async {
    try {
      final formData = FormData.fromMap({
        'photo': MultipartFile.fromBytes(
          photoBytes,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        ),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'accuracy': accuracy.toString(),
        'speed': speed.toString(),
        'heading': heading.toString(),
      });

      // Strip the global application/json header so Dio sets the correct
      // multipart/form-data content-type (with boundary) automatically.
      final response = await _dio.post(
        ApiConstants.trackingStart,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      return TrackingModel.fromJson(
        response.data['tracking'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] as String? ?? 'Unable to check in.',
      );
    }
  }

  // ─── Update Location (every 10 s) ───────────────────────────────────────
  // PUT /api/tracking/update
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
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': accuracy,
          'speed': speed,
          'heading': heading,
        },
      );

      return TrackingModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] as String? ?? 'Unable to update location.',
      );
    }
  }

  // ─── Stop Tracking (Check Out) ───────────────────────────────────────────
  // POST /api/tracking/stop
  Future<void> stopTracking({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _dio.post(
        ApiConstants.trackingStop,
        data: {'latitude': latitude, 'longitude': longitude},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] as String? ?? 'Unable to check out.',
      );
    }
  }

  // ─── Get My Tracking Status ──────────────────────────────────────────────
  // GET /api/tracking/status
  Future<({String status, TrackingModel? tracking})> getMyStatus() async {
    try {
      final response = await _dio.get(ApiConstants.trackingStatus);

      final String status = response.data['status']?.toString() ?? 'Offline';

      final dynamic trackingData = response.data['data'];

      return (
        status: status,
        tracking: trackingData == null
            ? null
            : TrackingModel.fromJson(trackingData as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] as String? ??
            'Unable to fetch tracking status.',
      );
    }
  }

  // ─── Get All Live Users (Admin) ──────────────────────────────────────────
  // GET /api/tracking/live
  Future<List<TrackingModel>> getLiveUsers() async {
    try {
      final response = await _dio.get(ApiConstants.trackingLive);
      final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => TrackingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] as String? ??
            'Unable to fetch live users.',
      );
    }
  }
}
