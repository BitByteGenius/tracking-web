import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/tracking_model.dart';
import '../config/app_config.dart';
import '../services/tracking_service.dart';
import 'attendance_controller.dart';

class TrackingController extends GetxController {
  final TrackingService _service = TrackingService();
  final ImagePicker _picker = ImagePicker();

  TrackingModel? _currentTracking;
  List<TrackingModel> _liveUsers = [];

  bool _isTracking = false;
  bool _loading = false;
  String _error = '';

  Timer? _timer;

  TrackingModel? get currentTracking => _currentTracking;
  List<TrackingModel> get liveUsers => _liveUsers;
  bool get isTracking => _isTracking;
  bool get loading => _loading;
  String get error => _error;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _setLoading(bool value) {
    _loading = value;
    update();
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _currentTracking = null;
    _liveUsers = [];
    _isTracking = false;
    _loading = false;
    _error = '';
    update();
  }

  // ──────────────────────────────────────────────
  // Sync tracking status after login / app restart
  // ──────────────────────────────────────────────
  Future<void> syncStatus() async {
    try {
      _error = '';
      final result = await _service.getMyStatus();

      _isTracking = result.status == 'Online';
      _currentTracking = result.tracking;

      if (_isTracking) {
        _startAutoUpdate();
      }

      update();
    } catch (e) {
      _error = _cleanError(e);
      update();
    }
  }

  // ──────────────────────────────────────────────
  // Start Tracking (Check In)
  // Flow: GPS → Camera → Upload → Start timer
  // ──────────────────────────────────────────────
  Future<void> startTracking() async {
    _setLoading(true);
    _error = '';

    try {
      // Step 1 – GPS
      final position = await _getCurrentPosition();

      // Step 2 – Camera (front, direct, no gallery)
      final photo = await _captureSelfie();
      if (photo == null) {
        // User cancelled camera – stop gracefully, no error shown.
        _setLoading(false);
        return;
      }

      // Step 3 – Upload + create attendance record
      _currentTracking = await _service.startTracking(
        photo: photo,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed < 0 ? 0 : position.speed,
        heading: position.heading < 0 ? 0 : position.heading,
      );

      _isTracking = true;

      // Step 4 – Reload attendance data
      await Get.find<AttendanceController>().reload();

      // Step 5 – Start 10-second location polling
      _startAutoUpdate();

      Get.snackbar(
        'Checked In',
        'You are now being tracked. Have a great day!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 3),
      );

      _setLoading(false);
    } catch (e) {
      final msg = _cleanError(e);

      // "Already checked in" → just re-sync state instead of showing error.
      if (msg.toLowerCase().contains('already checked in')) {
        await syncStatus();
        _setLoading(false);
        return;
      }

      _error = msg;
      _setLoading(false);

      Get.snackbar(
        'Check-In Failed',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // ──────────────────────────────────────────────
  // Stop Tracking (Check Out)
  // ──────────────────────────────────────────────
  Future<void> stopTracking() async {
    _setLoading(true);

    // Stop the timer immediately so no stray updates fire.
    _timer?.cancel();
    _timer = null;

    try {
      final position = await _getCurrentPosition();

      await _service.stopTracking(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _isTracking = false;
      _currentTracking = null;

      await Get.find<AttendanceController>().reload();

      _error = '';
      _setLoading(false);

      Get.snackbar(
        'Checked Out',
        'Your session has been saved. Great work!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      final msg = _cleanError(e);
      _error = msg;
      _setLoading(false);

      Get.snackbar(
        'Check-Out Failed',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // ──────────────────────────────────────────────
  // Auto location-update loop (every 10 s)
  // ──────────────────────────────────────────────
  void _startAutoUpdate() {
    _timer?.cancel();
    _timer = Timer.periodic(
      AppConfig.locationUpdateInterval,
      (_) => updateLocation(),
    );
  }

  // ──────────────────────────────────────────────
  // Push a single location update
  // ──────────────────────────────────────────────
  Future<void> updateLocation() async {
    if (!_isTracking) return;

    try {
      _error = '';
      final position = await _getCurrentPosition();

      _currentTracking = await _service.updateTracking(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed < 0 ? 0 : position.speed,
        heading: position.heading < 0 ? 0 : position.heading,
      );

      update();
    } catch (e) {
      // Silent – location update failures are non-critical.
      _error = _cleanError(e);
      update();
    }
  }

  // ──────────────────────────────────────────────
  // Fetch Live Users (Admin only)
  // ──────────────────────────────────────────────
  Future<void> fetchLiveUsers() async {
    try {
      _setLoading(true);
      _liveUsers = await _service.getLiveUsers();
      _error = '';
      _setLoading(false);
    } catch (e) {
      _error = _cleanError(e);
      _setLoading(false);
    }
  }

  // ──────────────────────────────────────────────
  // GPS helper
  // ──────────────────────────────────────────────
  Future<Position> _getCurrentPosition() async {
    // Web uses browser Geolocation API via geolocator – no OS service check.
    if (!kIsWeb) {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        throw Exception(
          'Location services are disabled. Please enable GPS and try again.',
        );
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception(
        'Location permission denied. Please allow location access.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. '
        'Please enable it in your device settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Camera selfie capture
  // • Android/iOS: opens front camera directly.
  // • Web: image_picker uses the browser file-input which accepts camera on
  //   supported browsers (Chrome/Safari on mobile). On desktop browsers that
  //   don't expose a front-camera, we show a clear message and return null.
  // ──────────────────────────────────────────────
  Future<XFile?> _captureSelfie() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 75,
        maxWidth: 1080,
        maxHeight: 1920,
      );
      return image; // null means user cancelled
    } catch (e) {
      final msg = e.toString().toLowerCase();

      // On Flutter Web, if the platform throws because camera is unavailable,
      // surface a clear, actionable message instead of a raw exception.
      if (kIsWeb &&
          (msg.contains('not supported') ||
              msg.contains('no camera') ||
              msg.contains('notallowederror') ||
              msg.contains('notfounderror'))) {
        Get.snackbar(
          'Camera Not Available',
          'Direct camera capture is not supported in this browser. '
              'Please use the mobile app for check-in.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
        return null;
      }

      // Re-throw so startTracking() shows the generic error snackbar.
      rethrow;
    }
  }

  // ──────────────────────────────────────────────
  // Clean error messages
  // ──────────────────────────────────────────────
  String _cleanError(Object e) {
    final raw = e.toString();
    if (raw.startsWith('Exception: ')) return raw.substring(11);
    return raw;
  }
}
