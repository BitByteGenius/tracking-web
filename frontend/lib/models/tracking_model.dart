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
  final double totalDistanceKm;
  final String attendanceId;

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
    this.totalDistanceKm = 0.0,
    this.attendanceId = "",
  });

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json["user"];
    final Map<String, dynamic> userMap = (rawUser is Map<String, dynamic>)
        ? rawUser
        : const {};
    final String resolvedUserId = userMap.isNotEmpty
        ? (userMap["_id"]?.toString() ?? "")
        : (rawUser?.toString() ?? "");

    return TrackingModel(
      id: json["_id"]?.toString() ?? "",
      userId: resolvedUserId,
      name: userMap["name"]?.toString() ?? "",
      email: userMap["email"]?.toString() ?? "",
      phone: userMap["phone"]?.toString() ?? "",
      latitude: _double(json["latitude"]),
      longitude: _double(json["longitude"]),
      accuracy: _double(json["accuracy"]),
      speed: _double(json["speed"]),
      heading: _double(json["heading"]),
      place: json["place"]?.toString() ?? "",
      city: json["city"]?.toString() ?? "",
      state: json["state"]?.toString() ?? "",
      country: json["country"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "Offline",
      lastSeen:
          DateTime.tryParse(json["lastSeen"]?.toString() ?? "")?.toLocal() ??
          DateTime.now(),
      totalDistanceKm: _double(
        json["totalDistanceKm"] ?? json["totalDistance"],
      ),
      attendanceId: json["attendance"] is Map<String, dynamic>
          ? json["attendance"]["_id"]?.toString() ?? ""
          : json["attendance"]?.toString() ??
                json["attendanceId"]?.toString() ??
                "",
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
      "totalDistanceKm": totalDistanceKm,
      "attendanceId": attendanceId,
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
    double? totalDistanceKm,
    String? attendanceId,
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
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      attendanceId: attendanceId ?? this.attendanceId,
    );
  }

  bool get isOnline => status == "Online";

  String get address => [
    place,
    city,
    state,
    country,
  ].where((part) => part.trim().isNotEmpty).join(", ");

  static double _double(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? "") ?? 0;
  }
}
