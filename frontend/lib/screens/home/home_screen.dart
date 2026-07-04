import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/attendance_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/routes/app_router.dart';
import '../../controllers/tracking_controller.dart';
import '../../models/attendance_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AttendanceController>().reload();
      Get.find<TrackingController>().syncStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (auth) => GetBuilder<AttendanceController>(
        builder: (attendance) => GetBuilder<TrackingController>(
          builder: (tracking) {
            final today = attendance.attendance;
            final current = tracking.currentTracking;
            final isWorking = tracking.isTracking || today?.status == 'Working';

            return Scaffold(
              appBar: AppBar(
                title: const Text('Employee Dashboard'),
                actions: [
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: () async {
                      await attendance.reload();
                      await tracking.syncStatus();
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    tooltip: 'Logout',
                    onPressed: () async {
                      await auth.logout();
                      Get.offAllNamed(AppRoutes.login);
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  await attendance.reload();
                  await tracking.syncStatus();
                },
                child: (attendance.loading && today == null)
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          _HeaderCard(
                            name: auth.user?.name ?? 'User',
                            role: auth.user?.role ?? 'user',
                            online: isWorking,
                          ),
                          const SizedBox(height: 16),

                          // Error banner
                          if (tracking.error.isNotEmpty ||
                              attendance.error.isNotEmpty)
                            _MessageCard(
                              message: tracking.error.isNotEmpty
                                  ? tracking.error
                                  : attendance.error,
                            ),

                          const SizedBox(height: 16),
                          _StatusCard(
                            attendance: today,
                            isWorking: isWorking,
                            distance:
                                current?.totalDistanceKm ??
                                today?.totalDistanceKm ??
                                0,
                          ),
                          const SizedBox(height: 16),

                          // ── Check In / Check Out button ────────────────
                          _CheckInOutButton(
                            loading: tracking.loading,
                            isWorking: isWorking,
                            onPressed: isWorking
                                ? () => _confirmCheckOut(tracking)
                                : () => tracking.startTracking(),
                          ),

                          const SizedBox(height: 16),
                          _TelemetryCard(
                            accuracy: current?.accuracy,
                            speed: current?.speed,
                            heading: current?.heading,
                            lastSeen: current?.lastSeen,
                            status:
                                current?.status ??
                                (isWorking ? 'Online' : 'Offline'),
                          ),
                          const SizedBox(height: 16),
                          _AddressCard(
                            address: current?.address.isNotEmpty == true
                                ? current!.address
                                : today?.address ?? '',
                          ),
                          const SizedBox(height: 16),
                          _SelfieCard(imageUrl: today?.selfie ?? ''),
                          const SizedBox(height: 16),
                          if (attendance.loading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else
                            _HistoryCard(history: attendance.history),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Confirmation dialog before check-out so users don't accidentally tap it.
  void _confirmCheckOut(TrackingController tracking) {
    Get.dialog(
      AlertDialog(
        title: const Text('Check Out'),
        content: const Text(
          'Are you sure you want to check out and end your work session?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Get.back();
              tracking.stopTracking();
            },
            child: const Text('Check Out'),
          ),
        ],
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.name,
    required this.role,
    required this.online,
  });

  final String name;
  final String role;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: cs.primaryContainer,
              child: Text(
                name.isEmpty ? 'U' : name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $name',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    role.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Chip(
              avatar: Icon(
                online
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 16,
                color: online ? Colors.green : Colors.grey,
              ),
              label: Text(online ? 'Tracking' : 'Offline'),
              backgroundColor: online
                  ? Colors.green.withValues(alpha: 0.12)
                  : Colors.grey.withValues(alpha: 0.12),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status ───────────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.attendance,
    required this.isWorking,
    required this.distance,
  });

  final AttendanceModel? attendance;
  final bool isWorking;
  final double distance;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Attendance",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricTile(
                  label: 'Status',
                  value: isWorking
                      ? 'Working'
                      : attendance?.status ?? 'Not checked in',
                ),
                _MetricTile(
                  label: 'Check In',
                  value: _fmt(attendance?.checkInTime),
                ),
                _MetricTile(
                  label: 'Check Out',
                  value: _fmt(attendance?.checkOutTime),
                ),
                _MetricTile(
                  label: 'Working Hours',
                  value: attendance?.workingHourText ?? '0h 0m',
                ),
                _MetricTile(
                  label: 'Distance',
                  value: '${distance.toStringAsFixed(2)} km',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Check In / Out Button ─────────────────────────────────────────────────────

class _CheckInOutButton extends StatelessWidget {
  const _CheckInOutButton({
    required this.loading,
    required this.isWorking,
    required this.onPressed,
  });

  final bool loading;
  final bool isWorking;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: isWorking
              ? Colors.red.shade600
              : Colors.green.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                isWorking ? Icons.logout : Icons.camera_alt,
                color: Colors.white,
              ),
        label: Text(
          loading
              ? (isWorking ? 'Checking Out…' : 'Opening Camera…')
              : (isWorking ? 'Check Out' : 'Check In with Selfie'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ── Telemetry ─────────────────────────────────────────────────────────────────

class _TelemetryCard extends StatelessWidget {
  const _TelemetryCard({
    required this.accuracy,
    required this.speed,
    required this.heading,
    required this.lastSeen,
    required this.status,
  });

  final double? accuracy;
  final double? speed;
  final double? heading;
  final DateTime? lastSeen;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricTile(label: 'Tracking Status', value: status),
            _MetricTile(
              label: 'GPS Accuracy',
              value: accuracy == null
                  ? '--'
                  : '${accuracy!.toStringAsFixed(1)} m',
            ),
            _MetricTile(
              label: 'Speed',
              value: speed == null ? '--' : '${speed!.toStringAsFixed(1)} m/s',
            ),
            _MetricTile(
              label: 'Heading',
              value: heading == null ? '--' : '${heading!.toStringAsFixed(0)}°',
            ),
            _MetricTile(label: 'Last Seen', value: _fmt(lastSeen)),
          ],
        ),
      ),
    );
  }
}

// ── Address ───────────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});
  final String address;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.place),
        title: const Text('Current Address'),
        subtitle: Text(address.isEmpty ? 'Address unavailable' : address),
      ),
    );
  }
}

// ── Selfie ────────────────────────────────────────────────────────────────────

class _SelfieCard extends StatelessWidget {
  const _SelfieCard({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Selfie",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl.isEmpty
                  ? Container(
                      height: 160,
                      width: double.infinity,
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No selfie captured today',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox(
                        height: 80,
                        child: Center(child: Text('Unable to load selfie')),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── History ───────────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.history});
  final List<AttendanceModel> history;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance History',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No attendance history yet')),
              )
            else
              ...history
                  .take(10)
                  .map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_available),
                      title: Text(item.attendanceDate),
                      subtitle: Text(
                        '${item.status} · ${item.workingHourText}',
                      ),
                      trailing: Text(
                        '${item.totalDistanceKm.toStringAsFixed(2)} km',
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ── Metric tile ───────────────────────────────────────────────────────────────

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 6),
              Text(value, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Card(
      color: color.withValues(alpha: 0.08),
      child: ListTile(
        leading: Icon(Icons.error_outline, color: color),
        title: Text(message, style: TextStyle(color: color)),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _fmt(DateTime? value) {
  if (value == null) return '--';
  return DateFormat('dd MMM, hh:mm a').format(value);
}
