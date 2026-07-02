import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../config/app_config.dart';
import '../models/tracking_model.dart';
import '../services/tracking_service.dart';

class TrackingProvider extends ChangeNotifier {
  final TrackingService _service = TrackingService();

  TrackingModel? _currentTracking;
  List<TrackingModel> _liveUsers = [];
  bool _isTracking = false;
  bool _loading = false;
  String _error = "";
  Timer? _timer;

  TrackingModel? get currentTracking => _currentTracking;
  List<TrackingModel>  get liveUsers   => _liveUsers;
  bool                 get isTracking  => _isTracking;
  bool                 get loading     => _loading;
  String               get error       => _error;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // ─── Sync Status (called after autoLogin on app restart) ───────────────
  // Queries GET /api/tracking/status so that _isTracking always reflects
  // the real MongoDB state, preventing false 409s on the next Check In.
  Future<void> syncStatus() async {
    try {
      final result = await _service.getMyStatus();
      _isTracking      = result.status == "Online";
      _currentTracking = result.tracking;
      _error           = "";
      notifyListeners();
    } catch (_) {
      // Network failure during sync: leave _isTracking as-is (false).
      // The user can still attempt Check In; the backend is the authority.
    }
  }

  // ─── Start Tracking ────────────────────────────────────────────────────
  Future<void> startTracking() async {
    try {
      _setLoading(true);
      _error = "";

      final position = await _getCurrentPosition();
      final address  = await _getAddress(position.latitude, position.longitude);

      _currentTracking = await _service.startTracking(
        latitude:  position.latitude,
        longitude: position.longitude,
        accuracy:  position.accuracy,
        speed:     position.speed  < 0 ? 0 : position.speed,
        heading:   position.heading < 0 ? 0 : position.heading,
        place:     address["place"]   ?? "",
        city:      address["city"]    ?? "",
        state:     address["state"]   ?? "",
        country:   address["country"] ?? "",
      );

      _isTracking = true;
      _startAutoUpdate();
      _setLoading(false);
    } catch (e) {
      final msg = _cleanError(e);
      // If the server confirmed the user is already checked in (409), sync
      // local state from the DB so the Check Out button becomes enabled
      // immediately — without requiring an app restart.
      // syncStatus() clears _error, so we re-set it afterwards.
      if (msg == "You are already checked in.") {
        await syncStatus();
      }
      _error = msg;
      _setLoading(false);
    }
  }

  // ─── Stop Tracking ─────────────────────────────────────────────────────
  Future<void> stopTracking() async {
    try {
      _setLoading(true);
      _timer?.cancel();
      _timer = null;

      await _service.stopTracking();

      _isTracking = false;
      _currentTracking = null;
      _error = "";
      _setLoading(false);
    } catch (e) {
      _error = _cleanError(e);
      _setLoading(false);
    }
  }

  // ─── Periodic Auto-Update ──────────────────────────────────────────────
  void _startAutoUpdate() {
    _timer?.cancel();
    _timer = Timer.periodic(
      AppConfig.locationUpdateInterval,
      (_) async => updateLocation(),
    );
  }

  // ─── Manual Location Update ────────────────────────────────────────────
  Future<void> updateLocation() async {
    if (!_isTracking) return;
    try {
      _error = "";
      final position = await _getCurrentPosition();
      final address  = await _getAddress(position.latitude, position.longitude);

      _currentTracking = await _service.updateTracking(
        latitude:  position.latitude,
        longitude: position.longitude,
        accuracy:  position.accuracy,
        speed:     position.speed  < 0 ? 0 : position.speed,
        heading:   position.heading < 0 ? 0 : position.heading,
        place:     address["place"]   ?? "",
        city:      address["city"]    ?? "",
        state:     address["state"]   ?? "",
        country:   address["country"] ?? "",
      );

      notifyListeners();
    } catch (e) {
      _error = _cleanError(e);
      notifyListeners();
    }
  }

  // ─── Fetch Live Users (Admin) ──────────────────────────────────────────
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

  // ─── Get Current GPS Position ──────────────────────────────────────────
  // Fixed: geolocator v14 removed the `desiredAccuracy` named parameter on
  // getCurrentPosition(). Must now pass a LocationSettings object instead.
  Future<Position> _getCurrentPosition() async {
    final bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception("Location services are disabled. Please enable them.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission is permanently denied.");
    }

    // geolocator ≥14.x API — use LocationSettings instead of desiredAccuracy
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  // ─── Reverse Geocode ───────────────────────────────────────────────────
  Future<Map<String, String>> _getAddress(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return {};
      final place = placemarks.first;
      return {
        "place":   place.street             ?? "",
        "city":    place.locality           ?? "",
        "state":   place.administrativeArea ?? "",
        "country": place.country            ?? "",
      };
    } catch (_) {
      return {};
    }
  }

  // ─── Helper: strip Dart's "Exception: " prefix ─────────────────────────
  // Dart's Exception.toString() always prepends "Exception: " to the message.
  // We strip it so SnackBars show the clean server message, not Dart internals.
  String _cleanError(Object e) {
    final raw = e.toString();
    if (raw.startsWith("Exception: ")) {
      return raw.substring("Exception: ".length);
    }
    return raw;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}