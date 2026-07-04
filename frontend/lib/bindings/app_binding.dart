import 'package:get/get.dart';

import '../controllers/admin_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/tracking_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    }
    if (!Get.isRegistered<AttendanceController>()) {
      Get.lazyPut<AttendanceController>(
        () => AttendanceController(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<TrackingController>()) {
      Get.lazyPut<TrackingController>(() => TrackingController(), fenix: true);
    }
    if (!Get.isRegistered<AdminController>()) {
      Get.lazyPut<AdminController>(() => AdminController(), fenix: true);
    }
  }
}
