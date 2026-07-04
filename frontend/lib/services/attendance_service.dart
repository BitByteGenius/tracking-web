import 'package:dio/dio.dart';

import '../models/attendance_model.dart';
import 'api_service.dart';

class AttendanceService {
  final Dio _dio = ApiService.instance.dio;

  Future<AttendanceModel?> getTodayAttendance() async {
    final response = await _dio.get("/attendance/today");
    final data = response.data["data"];

    if (data == null) {
      return null;
    }

    return AttendanceModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<AttendanceModel>> getHistory() async {
    final response = await _dio.get("/attendance/history");
    final data = response.data["data"] as List? ?? const [];

    return data
        .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AttendanceModel>> getAllAttendance() async {
    final response = await _dio.get("/attendance/all");
    final data = response.data["data"] as List? ?? const [];

    return data
        .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
