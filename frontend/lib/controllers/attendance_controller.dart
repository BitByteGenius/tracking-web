import 'package:get/get.dart';

import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class AttendanceController extends GetxController {
  final AttendanceService _service = AttendanceService();

  AttendanceModel? attendance;

  List<AttendanceModel> history = [];
  List<AttendanceModel> allAttendance = [];

  bool loading = false;

  String error = "";

  bool get isCheckedIn => attendance?.status == "Working";

  void reset() {
    attendance = null;
    history = [];
    allAttendance = [];
    loading = false;
    error = "";
    update();
  }

  Future<void> getTodayAttendance() async {
    try {
      loading = true;
      update();

      attendance = await _service.getTodayAttendance();

      error = "";
    } catch (e) {
      error = e.toString().replaceFirst("Exception: ", "");
    }

    loading = false;
    update();
  }

  Future<void> getHistory() async {
    try {
      loading = true;
      update();

      history = await _service.getHistory();

      error = "";
    } catch (e) {
      error = e.toString().replaceFirst("Exception: ", "");
    }

    loading = false;
    update();
  }

  Future<void> getAllAttendance() async {
    try {
      loading = true;
      update();

      allAttendance = await _service.getAllAttendance();
      error = "";
    } catch (e) {
      error = e.toString().replaceFirst("Exception: ", "");
    }

    loading = false;
    update();
  }

  Future<void> reload() async {
    await Future.wait([getTodayAttendance(), getHistory()]);
  }
}
