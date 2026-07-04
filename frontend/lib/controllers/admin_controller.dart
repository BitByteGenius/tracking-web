import 'package:get/get.dart';

import 'attendance_controller.dart';
import 'tracking_controller.dart';

class AdminController extends GetxController {
  AttendanceController get _attendance => Get.find<AttendanceController>();
  TrackingController get _tracking => Get.find<TrackingController>();

  Future<void> loadDashboard() async {
    await Future.wait([
      _tracking.fetchLiveUsers(),
      _attendance.getAllAttendance(),
    ]);
  }

  void clear() {
    _tracking.reset();
    _attendance.reset();
  }
}
