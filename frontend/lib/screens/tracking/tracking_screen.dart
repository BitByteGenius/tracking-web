import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/tracking_controller.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrackingController>(
      builder: (tracking) {
        final current = tracking.currentTracking;
        final isOnline = tracking.isTracking;

        return Scaffold(
          appBar: AppBar(title: const Text('Live Tracking'), centerTitle: true),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Status banner ────────────────────────────────────────
                _StatusBanner(isOnline: isOnline),
                const SizedBox(height: 20),

                // ── Location details ─────────────────────────────────────
                Card(
                  elevation: 0,
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
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
                              'Current Location',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 28),
                        _InfoRow(
                          label: 'Latitude',
                          value: current?.latitude.toStringAsFixed(6) ?? '--',
                        ),
                        _InfoRow(
                          label: 'Longitude',
                          value: current?.longitude.toStringAsFixed(6) ?? '--',
                        ),
                        _InfoRow(
                          label: 'Accuracy',
                          value: current == null
                              ? '--'
                              : '${current.accuracy.toStringAsFixed(1)} m',
                        ),
                        _InfoRow(
                          label: 'Speed',
                          value: current == null
                              ? '--'
                              : '${current.speed.toStringAsFixed(1)} m/s',
                        ),
                        _InfoRow(
                          label: 'Heading',
                          value: current == null
                              ? '--'
                              : '${current.heading.toStringAsFixed(0)}°',
                        ),
                        _InfoRow(
                          label: 'Distance',
                          value: current == null
                              ? '0.00 km'
                              : '${current.totalDistanceKm.toStringAsFixed(2)} km',
                        ),
                        _InfoRow(label: 'Place', value: current?.place ?? '--'),
                        _InfoRow(label: 'City', value: current?.city ?? '--'),
                        _InfoRow(label: 'State', value: current?.state ?? '--'),
                        _InfoRow(
                          label: 'Country',
                          value: current?.country ?? '--',
                        ),
                        _InfoRow(
                          label: 'Last Seen',
                          value: current == null
                              ? '--'
                              : DateFormat(
                                  'dd MMM, hh:mm:ss a',
                                ).format(current.lastSeen),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Action button ─────────────────────────────────────────
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: isOnline
                          ? Colors.red.shade600
                          : Colors.green.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: tracking.loading
                        ? null
                        : () {
                            if (isOnline) {
                              tracking.stopTracking();
                            } else {
                              tracking.startTracking();
                            }
                          },
                    icon: tracking.loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            isOnline ? Icons.stop_circle : Icons.play_circle,
                            color: Colors.white,
                          ),
                    label: Text(
                      tracking.loading
                          ? (isOnline ? 'Checking Out…' : 'Opening Camera…')
                          : (isOnline ? 'Check Out' : 'Check In with Selfie'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                // ── Error display ─────────────────────────────────────────
                if (tracking.error.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tracking.error,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Status Banner ─────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.isOnline});
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: isOnline
          ? Colors.green.withValues(alpha: 0.12)
          : Colors.red.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: isOnline ? Colors.green : Colors.red,
              child: Icon(
                isOnline ? Icons.location_on : Icons.location_off,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tracking Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOnline ? 'ONLINE' : 'OFFLINE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isOnline ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
