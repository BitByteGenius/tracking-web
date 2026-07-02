class TrackingModel {
  final String id;

  final String userId;
  final String name;
  final String email;
  final String phone;

  final double latitude;
  final double longitude;

  final double accuracy;
  final double speed;
  final double heading;

  final String place;
  final String city;
  final String state;
  final String country;

  final String status;

  final DateTime lastSeen;

  TrackingModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speed,
    required this.heading,
    required this.place,
    required this.city,
    required this.state,
    required this.country,
    required this.status,
    required this.lastSeen,
  });

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    // "user" can be one of two shapes depending on the endpoint:
    //
    //   Populated   (GET /tracking/live, /tracking/status with .populate()):
    //     { "_id": "...", "name": "Alice", "email": "...", ... }
    //
    //   Unpopulated (POST /tracking/start, /stop, /update — no .populate()):
    //     "507f1f77bcf86cd799439011"   ← raw ObjectId string
    //
    // The original code always did `user["_id"]` which threw a NoSuchMethodError
    // when user was a String, silently breaking syncStatus() and disabling
    // the Check Out button.
    final rawUser = json["user"];
    final Map<String, dynamic> userMap =
        (rawUser is Map<String, dynamic>) ? rawUser : const {};

    // When not populated, rawUser itself IS the userId string.
    final String resolvedUserId = userMap.isNotEmpty
        ? (userMap["_id"]?.toString() ?? "")
        : (rawUser?.toString() ?? "");

    return TrackingModel(
      id: json["_id"]?.toString() ?? "",

      userId: resolvedUserId,

      name: userMap["name"]?.toString() ?? "",

      email: userMap["email"]?.toString() ?? "",

      phone: userMap["phone"]?.toString() ?? "",

      latitude: (json["latitude"] ?? 0).toDouble(),

      longitude: (json["longitude"] ?? 0).toDouble(),

      accuracy: (json["accuracy"] ?? 0).toDouble(),

      speed: (json["speed"] ?? 0).toDouble(),

      heading: (json["heading"] ?? 0).toDouble(),

      place: json["place"]?.toString() ?? "",

      city: json["city"]?.toString() ?? "",

      state: json["state"]?.toString() ?? "",

      country: json["country"]?.toString() ?? "",

      status: json["status"]?.toString() ?? "Offline",

      lastSeen: DateTime.tryParse(
            json["lastSeen"]?.toString() ?? "",
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
      "accuracy": accuracy,
      "speed": speed,
      "heading": heading,
      "place": place,
      "city": city,
      "state": state,
      "country": country,
      "status": status,
      "lastSeen": lastSeen.toIso8601String(),
    };
  }

  TrackingModel copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? speed,
    double? heading,
    String? place,
    String? city,
    String? state,
    String? country,
    String? status,
    DateTime? lastSeen,
  }) {
    return TrackingModel(
      id: id,
      userId: userId,
      name: name,
      email: email,
      phone: phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      place: place ?? this.place,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  bool get isOnline => status == "Online";
}