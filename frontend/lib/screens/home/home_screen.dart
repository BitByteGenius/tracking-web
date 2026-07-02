import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/tracking_provider.dart';

/// User Dashboard — shows only Check In and Check Out actions.
/// Displays the user's name, email, and current tracking status.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthProvider>();
    final tracking = context.watch<TrackingProvider>();

    final bool isCheckedIn = tracking.isTracking;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            onPressed: () async {
              // If user is checked in, check out before logging out
              if (isCheckedIn) {
                await tracking.stopTracking();
              }
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, "/login");
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // ── User Avatar ────────────────────────────────────────────
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.person, size: 50, color: Colors.blue),
              ),

              const SizedBox(height: 16),

              Text(
                auth.user?.name ?? "",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                auth.user?.email ?? "",
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 32),

              // ── Status Card ────────────────────────────────────────────
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor:
                            isCheckedIn ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isCheckedIn ? "CHECKED IN" : "CHECKED OUT",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isCheckedIn ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── Check In Button ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: tracking.loading && !isCheckedIn
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.login),
                  label: const Text(
                    "Check In",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  // Disable if already checked in OR loading
                  onPressed: (isCheckedIn || tracking.loading)
                      ? null
                      : () async {
                          await tracking.startTracking();
                          if (!context.mounted) return;
                          final err = tracking.error;
                          if (err.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(err),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("✅ Checked in successfully"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                ),
              ),

              const SizedBox(height: 16),

              // ── Check Out Button ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: tracking.loading && isCheckedIn
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.logout),
                  label: const Text(
                    "Check Out",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  // Disable if not checked in OR loading
                  onPressed: (!isCheckedIn || tracking.loading)
                      ? null
                      : () async {
                          await tracking.stopTracking();
                          if (!context.mounted) return;
                          final err = tracking.error;
                          if (err.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(err),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("✅ Checked out successfully"),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                ),
              ),

              // ── Show current coordinates when checked in ───────────────
              if (isCheckedIn && tracking.currentTracking != null) ...[
                const SizedBox(height: 32),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.my_location, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              "Current Location",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _infoRow(
                          "Latitude",
                          tracking.currentTracking!.latitude
                              .toStringAsFixed(6),
                        ),
                        _infoRow(
                          "Longitude",
                          tracking.currentTracking!.longitude
                              .toStringAsFixed(6),
                        ),
                        if (tracking.currentTracking!.city.isNotEmpty)
                          _infoRow("City", tracking.currentTracking!.city),
                        if (tracking.currentTracking!.country.isNotEmpty)
                          _infoRow(
                            "Country",
                            tracking.currentTracking!.country,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}