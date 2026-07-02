import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/api_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/tracking_provider.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Log the active API endpoint in debug mode
  assert(() {
    // ignore: avoid_print
    print("🌐 API Base URL: ${ApiConstants.baseUrl}");
    return true;
  }());

  runApp(const LiveTrackingApp());
}

class LiveTrackingApp extends StatelessWidget {
  const LiveTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<TrackingProvider>(
          create: (_) => TrackingProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Live Tracking System",
        theme: AppTheme.lightTheme,

        // Named route navigation — see routes/app_router.dart
        initialRoute: "/",
        routes: AppRouter.routes,
      ),
    );
  }
}