import 'package:flutter/material.dart';

import '../screens/admin/admin_dashboard.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/tracking/tracking_screen.dart';

class AppRouter {
  static final Map<String, WidgetBuilder> routes = {
    "/": (context) => const SplashScreen(),

    "/login": (context) => const LoginScreen(),

    "/register": (context) => const RegisterScreen(),

    "/home": (context) => const HomeScreen(),

    "/tracking": (context) => const TrackingScreen(),

    "/admin": (context) => const AdminDashboard(),
  };
}