import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../config/app_config.dart';
import '../models/tracking_model.dart';
import '../services/selfie_capture_service.dart';
import '../services/tracking_service.dart';
import 'attendance_controller.dart';

class TrackingController extends GetxController {
  final TrackingService _service = TrackingService();
  final SelfieCaptureService _selfieCaptureService = SelfieCaptureService();

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

  Future<void> startTracking() async {
    _setLoading(true);
    _error = '';

    try {
      final position = await _getCurrentPosition();
      final photo = await _captureSelfie();
      if (photo == null) {
        _setLoading(false);
        return;
      }

      _currentTracking = await _service.startTracking(
        photoBytes: photo.bytes,
        filename: photo.filename,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed < 0 ? 0 : position.speed,
        heading: position.heading < 0 ? 0 : position.heading,
      );

      _isTracking = true;
      await Get.find<AttendanceController>().reload();
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

  Future<void> stopTracking() async {
    _setLoading(true);
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

  void _startAutoUpdate() {
    _timer?.cancel();
    _timer = Timer.periodic(
      AppConfig.locationUpdateInterval,
      (_) => updateLocation(),
    );
  }

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
      _error = _cleanError(e);
      update();
    }
  }

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

  Future<Position> _getCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Location services are disabled. Please enable GPS and try again.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied. Please allow location access.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is permanently denied. Please enable it in your device settings.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }

  Future<CapturedSelfie?> _captureSelfie() async {
    return _selfieCaptureService.capture();
  }

  String _cleanError(Object e) {
    final raw = e.toString();
    if (raw.startsWith('Exception: ')) return raw.substring(11);
    return raw;
  }
}
