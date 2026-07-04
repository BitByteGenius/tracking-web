import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app_config.dart';
import '../../controllers/auth_controller.dart';
import '../../core/routes/app_router.dart';

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
    await Future.delayed(AppConfig.splashDuration);

    if (!mounted) return;

    final auth = Get.find<AuthController>();
    final loggedIn = await auth.autoLogin();

    if (!mounted) return;

    if (loggedIn) {
      Get.offAllNamed(
        auth.user?.isAdmin == true ? AppRoutes.admin : AppRoutes.home,
      );
    } else {
      Get.offAllNamed(AppRoutes.login);
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
              'Live Tracking',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
