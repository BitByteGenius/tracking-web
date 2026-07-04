import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/app_binding.dart';
import 'core/constants/api_constants.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    debugPrint("API Base URL: ${ApiConstants.baseUrl}");
  }

  runApp(const LiveTrackingApp());
}

class LiveTrackingApp extends StatelessWidget {
  const LiveTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Live Tracking System",
      theme: AppTheme.lightTheme,

      initialBinding: AppBinding(),

      initialRoute: AppRoutes.splash,

      getPages: AppRouter.pages,
    );
  }
}
