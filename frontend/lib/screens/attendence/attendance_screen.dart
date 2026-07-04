import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/attendance_controller.dart';
import '../../models/attendance_model.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AttendanceController>(
      builder: (controller) {
        final attendance = controller.attendance;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Attendance",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: controller.loading
              ? const Center(child: CircularProgressIndicator())
              : attendance == null
              ? const Center(
                  child: Text(
                    "No attendance found for today",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: controller.reload,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _statusCard(attendance),

                      const SizedBox(height: 20),

                      _timeCard(attendance),

                      const SizedBox(height: 20),

                      _distanceCard(attendance),

                      const SizedBox(height: 20),

                      _locationCard(attendance),

                      const SizedBox(height: 20),

                      _selfieCard(attendance.selfie),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _statusCard(AttendanceModel attendance) {
    final checkedIn = attendance.status == "Working";

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: checkedIn ? Colors.green : Colors.orange,
          child: Icon(
            checkedIn ? Icons.check : Icons.logout,
            color: Colors.white,
          ),
        ),
        title: Text(
          checkedIn ? "Checked In" : attendance.status,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(attendance.attendanceDate),
      ),
    );
  }

  Widget _timeCard(AttendanceModel attendance) {
    String format(DateTime? time) {
      if (time == null) return "--";
      return DateFormat("dd MMM yyyy, hh:mm a").format(time);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text("Check In"),
              trailing: Text(format(attendance.checkInTime)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Check Out"),
              trailing: Text(format(attendance.checkOutTime)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _distanceCard(AttendanceModel attendance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text("Working Time"),
              trailing: Text(
                "${attendance.workingMinutes ~/ 60}h "
                "${attendance.workingMinutes % 60}m",
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.route),
              title: const Text("Distance"),
              trailing: Text(
                "${attendance.totalDistanceKm.toStringAsFixed(2)} KM",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationCard(AttendanceModel attendance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Location",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 15),
            Text("Place : ${attendance.place}"),
            Text("City : ${attendance.city}"),
            Text("State : ${attendance.state}"),
            Text("Country : ${attendance.country}"),
          ],
        ),
      ),
    );
  }

  Widget _selfieCard(String image) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selfie",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: image.isEmpty
                  ? Container(
                      height: 220,
                      color: Colors.grey.shade300,
                      child: const Center(child: Text("No Selfie")),
                    )
                  : Image.network(
                      image,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
