import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../models/tracking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tracking_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final MapController _mapController = MapController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Fetch immediately after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });

    // Auto-refresh every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _loadUsers());
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;

    final provider = Provider.of<TrackingProvider>(context, listen: false);
    await provider.fetchLiveUsers();

    if (!mounted) return;

    // Pan map camera to first online user after data loads
    if (provider.liveUsers.isNotEmpty) {
      final first = provider.liveUsers.first;
      _mapController.move(
        LatLng(first.latitude, first.longitude),
        15,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrackingProvider>();
    final auth     = context.read<AuthProvider>();
    final users    = provider.liveUsers;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Live Tracking Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),

      body: Column(
        children: [

          // ─── TomTom Map ───────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: users.isNotEmpty
                    ? LatLng(users.first.latitude, users.first.longitude)
                    : const LatLng(20.5937, 78.9629), // Default: centre of India
                initialZoom: users.isNotEmpty ? 15 : 5,
              ),
              children: [

                // ── TomTom base tile layer ────────────────────────────────
                // urlTemplate uses {z}/{x}/{y} replaced by flutter_map,
                // and {apiKey} replaced from additionalOptions.
                TileLayer(
                  urlTemplate:
                      'https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png'
                      '?key={apiKey}',
                  additionalOptions: const {
                    'apiKey': AppConfig.tomtomApiKey,
                  },
                  // Identifies the app to TomTom's tile servers (good practice)
                  userAgentPackageName: 'com.livetracking.app',
                ),

                // ── Live user markers ─────────────────────────────────────
                MarkerLayer(
                  markers: users.map((TrackingModel user) {
                    return Marker(
                      point: LatLng(user.latitude, user.longitude),
                      width:  56,
                      height: 64,
                      child: GestureDetector(
                        onTap: () {
                          // Tap marker → centre map on that user, same as original
                          _mapController.move(
                            LatLng(user.latitude, user.longitude),
                            18,
                          );
                        },
                        child: Tooltip(
                          // Replaces GoogleMaps InfoWindow
                          message: '${user.name}\n${user.city}, ${user.state}',
                          preferBelow: false,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 48,
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: Colors.black45,
                                offset: Offset(1, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // ─── Online count banner ──────────────────────────────────────
          Container(
            width: double.infinity,
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              'Online Users: ${users.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          // ─── User list ────────────────────────────────────────────────
          Expanded(
            child: users.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No Users Currently Online',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Waiting for users to check in…',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final TrackingModel user = users[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor:
                                user.isOnline ? Colors.green : Colors.red,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),

                          title: Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(user.email),
                              Text('${user.place}, ${user.city}'),
                              Text('${user.state}, ${user.country}'),
                              Text('Latitude : ${user.latitude}'),
                              Text('Longitude: ${user.longitude}'),
                              Text('Speed    : ${user.speed.toStringAsFixed(2)} m/s'),
                              Text('Accuracy : ${user.accuracy.toStringAsFixed(1)} m'),
                              Text(
                                'Last Seen: ${DateFormat('dd MMM yyyy, hh:mm a').format(user.lastSeen.toLocal())}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),

                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 14,
                                color: user.isOnline
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                user.status,
                                style: TextStyle(
                                  color: user.isOnline
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          // Tap a user row → focus their location on the map
                          onTap: () {
                            _mapController.move(
                              LatLng(user.latitude, user.longitude),
                              18,
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
