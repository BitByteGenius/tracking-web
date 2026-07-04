import 'dart:async';
import 'dart:io';

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
  String _error = "";

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
    _error = "";
    update();
  }

  //──────────────────────────────────────────────
  // Sync tracking status after login/app restart
  //──────────────────────────────────────────────
  Future<void> syncStatus() async {
    try {
      _error = "";
      final result = await _service.getMyStatus();

      _isTracking = result.status == "Online";
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

  //──────────────────────────────────────────────
  // Start Tracking
  //──────────────────────────────────────────────
  Future<void> startTracking() async {
    try {
      _setLoading(true);
      _error = "";

      final position = await _getCurrentPosition();

      final photo = await _pickSelfie();

      if (photo == null) {
        _setLoading(false);
        return;
      }

      _currentTracking = await _service.startTracking(
        photo: photo,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed < 0 ? 0 : position.speed,
        heading: position.heading < 0 ? 0 : position.heading,
      );

      _isTracking = true;

      await Get.find<AttendanceController>().reload();

      _startAutoUpdate();

      _setLoading(false);
    } catch (e) {
      final msg = _cleanError(e);

      if (msg == "You are already checked in.") {
        await syncStatus();
      }

      _error = msg;
      _setLoading(false);
    }
  }

  //──────────────────────────────────────────────
  // Stop Tracking
  //──────────────────────────────────────────────
  Future<void> stopTracking() async {
    try {
      _setLoading(true);

      _timer?.cancel();
      _timer = null;

      final position = await _getCurrentPosition();

      await _service.stopTracking(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _isTracking = false;
      _currentTracking = null;

      await Get.find<AttendanceController>().reload();

      _error = "";
      _setLoading(false);
    } catch (e) {
      _error = _cleanError(e);
      _setLoading(false);
    }
  }

  //──────────────────────────────────────────────
  // Auto Update
  //──────────────────────────────────────────────
  void _startAutoUpdate() {
    _timer?.cancel();

    _timer = Timer.periodic(
      AppConfig.locationUpdateInterval,
      (_) => updateLocation(),
    );
  }

  //──────────────────────────────────────────────
  // Update Location
  //──────────────────────────────────────────────
  Future<void> updateLocation() async {
    if (!_isTracking) return;

    try {
      _error = "";

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

  //──────────────────────────────────────────────
  // Fetch Live Users (Admin)
  //──────────────────────────────────────────────
  Future<void> fetchLiveUsers() async {
    try {
      _setLoading(true);

      _liveUsers = await _service.getLiveUsers();

      _error = "";
      _setLoading(false);
    } catch (e) {
      _error = _cleanError(e);
      _setLoading(false);
    }
  }

  //──────────────────────────────────────────────
  // Get Current Location
  //──────────────────────────────────────────────
  Future<Position> _getCurrentPosition() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      throw Exception("Location service is disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied.");
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied forever.");
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  //──────────────────────────────────────────────
  // Capture Selfie
  //──────────────────────────────────────────────
  Future<File?> _pickSelfie() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 70,
    );

    if (image == null) return null;

    return File(image.path);
  }

  //──────────────────────────────────────────────
  // Clean Error
  //──────────────────────────────────────────────
  String _cleanError(Object e) {
    final raw = e.toString();

    if (raw.startsWith("Exception: ")) {
      return raw.substring(11);
    }

    return raw;
  }
}
