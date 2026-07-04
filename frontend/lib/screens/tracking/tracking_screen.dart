import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/tracking_controller.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrackingController>(
      builder: (tracking) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Live Tracking",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  color: tracking.isTracking
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: tracking.isTracking
                              ? Colors.green
                              : Colors.red,
                          child: Icon(
                            tracking.isTracking
                                ? Icons.location_on
                                : Icons.location_off,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tracking Status",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tracking.isTracking ? "ONLINE" : "OFFLINE",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: tracking.isTracking
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.my_location,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Current Location",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 30),
                        _InfoRow(
                          title: "Latitude",
                          value:
                              tracking.currentTracking?.latitude
                                  .toStringAsFixed(6) ??
                              "--",
                        ),

                        _InfoRow(
                          title: "Longitude",
                          value:
                              tracking.currentTracking?.longitude
                                  .toStringAsFixed(6) ??
                              "--",
                        ),

                        _InfoRow(
                          title: "Accuracy",
                          value:
                              "${tracking.currentTracking?.accuracy.toStringAsFixed(2) ?? "--"} m",
                        ),

                        _InfoRow(
                          title: "Speed",
                          value:
                              "${tracking.currentTracking?.speed.toStringAsFixed(2) ?? "--"} m/s",
                        ),

                        _InfoRow(
                          title: "Heading",
                          value:
                              "${tracking.currentTracking?.heading.toStringAsFixed(2) ?? "--"}°",
                        ),

                        // NEW
                        _InfoRow(
                          title: "Distance",
                          value:
                              "${tracking.currentTracking?.totalDistanceKm.toStringAsFixed(2) ?? "0.00"} KM",
                        ),

                        // NEW
                        _InfoRow(
                          title: "Place",
                          value: tracking.currentTracking?.place ?? "--",
                        ),

                        _InfoRow(
                          title: "City",
                          value: tracking.currentTracking?.city ?? "--",
                        ),

                        _InfoRow(
                          title: "State",
                          value: tracking.currentTracking?.state ?? "--",
                        ),

                        _InfoRow(
                          title: "Country",
                          value: tracking.currentTracking?.country ?? "--",
                        ),

                        // NEW
                        _InfoRow(
                          title: "Last Seen",
                          value:
                              tracking.currentTracking?.lastSeen.toString() ??
                              "--",
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: tracking.isTracking
                        ? Colors.red
                        : Colors.green,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: tracking.loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          tracking.isTracking ? Icons.stop : Icons.play_arrow,
                        ),
                  label: Text(
                    tracking.isTracking ? "CHECK OUT" : "CHECK IN",

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  onPressed: tracking.loading
                      ? null
                      : () async {
                          if (tracking.isTracking) {
                            await tracking.stopTracking();
                          } else {
                            await tracking.startTracking();
                          }
                          if (tracking.error.isNotEmpty) {
                            Get.snackbar(
                              "Error",
                              tracking.error,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
