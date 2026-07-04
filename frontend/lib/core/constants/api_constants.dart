/// API endpoint constants.
///
/// DEVELOPMENT:
///   - Android Emulator  →  http://10.0.2.2:3000/api
///   - Physical device (same WiFi) → http://YOUR_PC_LAN_IP:3000/api
///   - Flutter Web (localhost)     → http://localhost:3000/api
///
/// PRODUCTION:
///   Change [baseUrl] to your deployed backend URL.
class ApiConstants {
  ApiConstants._();

  /// ─── Change this to switch environments ───────────────────────────────
  //static const String baseUrl = "http://localhost:3000/api";
  static const String baseUrl = "https://tracking-web-mbsx.onrender.com/api";

  // Auth endpoints (relative to baseUrl)
  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String adminLogin = "/auth/admin-login";

  // Tracking endpoints (relative to baseUrl)
  static const String trackingStart = "/tracking/start";
  static const String trackingUpdate = "/tracking/update";
  static const String trackingStop = "/tracking/stop";
  static const String trackingStatus =
      "/tracking/status"; // own status (for app-restart sync)
  static const String trackingLive = "/tracking/live";

  static const Duration timeout = Duration(seconds: 30);
}
