class AppConfig {
  AppConfig._();

  static const String appName = "Live Tracking System";

  static const bool enableLogs = true;

  static const Duration locationUpdateInterval = Duration(seconds: 10);

  static const Duration splashDuration = Duration(seconds: 2);

  // ── TomTom Maps API key ───────────────────────────────────────────────────
  // This key is intentionally in frontend config. Map tile requests originate
  // from the browser, so the key must be available client-side — identical to
  // how every Maps SDK works (Google, Mapbox, HERE, etc.).
  // Restrict allowed referer domains in the TomTom Developer Portal to
  // prevent abuse instead of treating this as a server-side secret.
  static const String tomtomApiKey = "L2PEltSCfIxQHYL0iB1rUY8eISgWWAEl";
}
