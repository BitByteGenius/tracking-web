import 'package:get/get.dart';

import '../../screens/admin/admin_dashboard.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/settings_screen.dart';
import '../../screens/home/profile_screen.dart';
import '../../screens/attendence/attendance_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/tracking/tracking_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = "/";
  static const login = "/login";
  static const register = "/register";
  static const home = "/home";
  static const tracking = "/tracking";
  static const attendance = "/attendance";
  static const admin = "/admin";
  static const profile = "/profile";
  static const settings = "/settings";
}

class AppRouter {
  static final pages = <GetPage>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),

    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),

    GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),

    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),

    GetPage(name: AppRoutes.tracking, page: () => const TrackingScreen()),

    GetPage(name: AppRoutes.attendance, page: () => const AttendanceScreen()),

    GetPage(name: AppRoutes.admin, page: () => const AdminDashboard()),

    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),

    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
  ];
}
