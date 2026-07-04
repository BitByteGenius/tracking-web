import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../config/app_config.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/routes/app_router.dart';
import '../../controllers/tracking_controller.dart';
import '../../models/attendance_model.dart';
import '../../models/tracking_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _timer;
  String _query = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _refresh());
  }

  Future<void> _refresh() async {
    final tracking = Get.find<TrackingController>();
    final attendance = Get.find<AttendanceController>();
    await Future.wait([
      tracking.fetchLiveUsers(),
      attendance.getAllAttendance(),
    ]);

    if (!mounted || tracking.liveUsers.isEmpty) return;
    final first = tracking.liveUsers.first;
    _mapController.move(LatLng(first.latitude, first.longitude), 13);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrackingController>(
      builder: (tracking) => GetBuilder<AttendanceController>(
        builder: (attendance) {
          final liveUsers = tracking.liveUsers.where(_matchesTracking).toList();
          final records = attendance.allAttendance
              .where(_matchesAttendance)
              .toList();
          final present = attendance.allAttendance
              .where((item) => item.status == "Present")
              .length;
          final working = attendance.allAttendance
              .where((item) => item.status == "Working")
              .length;

          return Scaffold(
            appBar: AppBar(
              title: const Text("Admin Dashboard"),
              actions: [
                IconButton(
                  tooltip: "Refresh",
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  tooltip: "Logout",
                  onPressed: () async {
                    await Get.find<AuthController>().logout();
                    Get.offAllNamed(AppRoutes.login);
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _refresh,
              child: (tracking.loading && tracking.liveUsers.isEmpty)
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _SummaryCard(
                              icon: Icons.people,
                              label: "Attendance Records",
                              value: attendance.allAttendance.length.toString(),
                            ),
                            _SummaryCard(
                              icon: Icons.location_on,
                              label: "Live Users",
                              value: tracking.liveUsers.length.toString(),
                            ),
                            _SummaryCard(
                              icon: Icons.work_history,
                              label: "Working",
                              value: working.toString(),
                            ),
                            _SummaryCard(
                              icon: Icons.verified,
                              label: "Present",
                              value: present.toString(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            labelText: "Search employees",
                          ),
                          onChanged: (value) =>
                              setState(() => _query = value.trim()),
                        ),
                        const SizedBox(height: 16),
                        _MapCard(
                          users: liveUsers,
                          mapController: _mapController,
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: "Live Users",
                          emptyText: "No employees are currently online",
                          children: liveUsers
                              .map((user) => _LiveUserTile(user: user))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: "Attendance Overview",
                          emptyText: "No attendance records found",
                          children: records
                              .take(30)
                              .map((item) => _AttendanceTile(attendance: item))
                              .toList(),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  bool _matchesTracking(TrackingModel user) {
    if (_query.isEmpty) return true;
    final haystack = "${user.name} ${user.email} ${user.phone} ${user.address}"
        .toLowerCase();
    return haystack.contains(_query.toLowerCase());
  }

  bool _matchesAttendance(AttendanceModel item) {
    if (_query.isEmpty) return true;
    final user = item.user;
    final haystack =
        "${user?.name ?? ""} ${user?.email ?? ""} ${user?.phone ?? ""} ${item.status} ${item.address}"
            .toLowerCase();
    return haystack.contains(_query.toLowerCase());
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(child: Icon(icon)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.labelLarge),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.users, required this.mapController});

  final List<TrackingModel> users;
  final MapController mapController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: users.isEmpty
                ? const LatLng(20.5937, 78.9629)
                : LatLng(users.first.latitude, users.first.longitude),
            initialZoom: users.isEmpty ? 5 : 13,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  "https://api.tomtom.com/map/1/tile/basic/main/{z}/{x}/{y}.png?key={apiKey}",
              additionalOptions: const {"apiKey": AppConfig.tomtomApiKey},
              userAgentPackageName: "com.livetracking.app",
            ),
            MarkerLayer(
              markers: users.map((user) {
                return Marker(
                  point: LatLng(user.latitude, user.longitude),
                  width: 48,
                  height: 48,
                  child: IconButton.filled(
                    tooltip: user.name.isEmpty ? "Employee" : user.name,
                    onPressed: () => _showUserSheet(context, user),
                    icon: const Icon(Icons.person_pin_circle),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserSheet(BuildContext context, TrackingModel user) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name.isEmpty ? "Employee" : user.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(user.email),
            const SizedBox(height: 12),
            Text(user.address.isEmpty ? "Address unavailable" : user.address),
            const SizedBox(height: 12),
            Text("Distance: ${user.totalDistanceKm.toStringAsFixed(2)} km"),
            Text("Last seen: ${_format(user.lastSeen)}"),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.emptyText,
    required this.children,
  });

  final String title;
  final String emptyText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (children.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(child: Text(emptyText)),
              )
            else
              ...children,
          ],
        ),
      ),
    );
  }
}

class _LiveUserTile extends StatelessWidget {
  const _LiveUserTile({required this.user});

  final TrackingModel user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(child: Icon(Icons.location_on)),
      title: Text(user.name.isEmpty ? "Employee" : user.name),
      subtitle: Text(user.address.isEmpty ? user.email : user.address),
      trailing: Text("${user.totalDistanceKm.toStringAsFixed(2)} km"),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({required this.attendance});

  final AttendanceModel attendance;

  @override
  Widget build(BuildContext context) {
    final user = attendance.user;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: Text(
          (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : "?",
        ),
      ),
      title: Text(user?.name ?? "Employee"),
      subtitle: Text("${attendance.attendanceDate} - ${attendance.status}"),
      trailing: Text(attendance.workingHourText),
    );
  }
}

String _format(DateTime value) => DateFormat("dd MMM, hh:mm a").format(value);
