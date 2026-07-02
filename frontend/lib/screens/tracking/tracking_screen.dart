import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tracking_provider.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final tracking = context.watch<TrackingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Tracking"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            //==========================
            // STATUS CARD
            //==========================

            Card(
              elevation: 4,
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
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "Tracking Status",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            tracking.isTracking
                                ? "ONLINE"
                                : "OFFLINE",
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
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            //==========================
            // LOCATION CARD
            //==========================

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    const Row(
                      children: [

                        Icon(Icons.my_location),

                        SizedBox(width: 10),

                        Text(
                          "Current Location",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      ],
                    ),

                    const Divider(height: 30),

                    infoTile(
                      "Latitude",
                      tracking.currentTracking?.latitude
                              .toStringAsFixed(6) ??
                          "--",
                    ),

                    infoTile(
                      "Longitude",
                      tracking.currentTracking?.longitude
                              .toStringAsFixed(6) ??
                          "--",
                    ),

                    infoTile(
                      "Accuracy",
                      "${tracking.currentTracking?.accuracy.toStringAsFixed(2) ?? "--"} m",
                    ),

                    infoTile(
                      "Speed",
                      "${tracking.currentTracking?.speed.toStringAsFixed(2) ?? "--"} m/s",
                    ),

                    infoTile(
                      "Heading",
                      "${tracking.currentTracking?.heading.toStringAsFixed(2) ?? "--"}°",
                    ),

                    infoTile(
                      "City",
                      tracking.currentTracking?.city ?? "--",
                    ),

                    infoTile(
                      "State",
                      tracking.currentTracking?.state ?? "--",
                    ),

                    infoTile(
                      "Country",
                      tracking.currentTracking?.country ?? "--",
                    ),

                    infoTile(
                      "Last Seen",
                      tracking.currentTracking?.lastSeen
                              .toString() ??
                          "--",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            //==========================
            // BUTTON
            //==========================

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tracking.isTracking
                      ? Colors.red
                      : Colors.green,
                ),
                icon: Icon(
                  tracking.isTracking
                      ? Icons.stop
                      : Icons.play_arrow,
                  color: Colors.white,
                ),
                label: tracking.loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(
                        tracking.isTracking
                            ? "STOP TRACKING"
                            : "START TRACKING",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                onPressed: tracking.loading
                    ? null
                    : () async {
                        // Capture messenger before the async gap
                        final messenger = ScaffoldMessenger.of(context);

                        if (tracking.isTracking) {

                          await tracking.stopTracking();

                        } else {

                          await tracking.startTracking();

                        }

                        if (!mounted) return;

                        if (tracking.error.isNotEmpty) {
                          messenger.showSnackBar(
                            SnackBar(
                              content:
                                  Text(tracking.error),
                            ),
                          );
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}