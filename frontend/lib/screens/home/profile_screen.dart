import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                (user?.name.isNotEmpty ?? false)
                    ? user!.name[0].toUpperCase()
                    : "U",
              ),
            ),
            title: Text(user?.name ?? "User"),
            subtitle: Text(user?.email ?? ""),
          ),
        ),
      ),
    );
  }
}
