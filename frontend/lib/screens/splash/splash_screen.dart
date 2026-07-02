import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tracking_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // Respect the configured splash duration before navigating
    await Future.delayed(AppConfig.splashDuration);

    if (!mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final loggedIn = await auth.autoLogin();

    if (!mounted) return;

    if (loggedIn) {
      // Sync tracking state with the backend BEFORE navigating to home,
      // so _isTracking reflects the real MongoDB status (not always false).
      // Skip sync for admin — they have no tracking record.
      if (auth.user != null && !auth.user!.isAdmin) {
        final tracking = Provider.of<TrackingProvider>(context, listen: false);
        await tracking.syncStatus();
      }

      if (!mounted) return;

      // Redirect admin to admin dashboard, regular users to home
      if (auth.user != null && auth.user!.isAdmin) {
        Navigator.pushReplacementNamed(context, "/admin");
      } else {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } else {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              "Live Tracking",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}