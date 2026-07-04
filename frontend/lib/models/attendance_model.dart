class AttendanceModel {
  final String id;
  final String attendanceDate;
  final String status;

  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  final double totalDistanceKm;
  final int workingMinutes;

  final String selfie;

  final double latitude;
  final double longitude;

  final String place;
  final String city;
  final String state;
  final String country;
  final UserSummary? user;

  AttendanceModel({
    required this.id,
    required this.attendanceDate,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    required this.totalDistanceKm,
    required this.workingMinutes,
    required this.selfie,
    required this.latitude,
    required this.longitude,
    required this.place,
    required this.city,
    required this.state,
    required this.country,
    this.user,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final checkIn = json["checkIn"] as Map<String, dynamic>?;
    final checkOut = json["checkOut"] as Map<String, dynamic>?;
    final rawUser = json["user"];
    return AttendanceModel(
      id: json["_id"] ?? "",
      attendanceDate: json["attendanceDate"] ?? "",
      status: json["status"] ?? "",
      checkInTime: _date(checkIn?["time"]),
      checkOutTime: _date(checkOut?["time"]),
      latitude: _double(checkIn?["latitude"]),
      longitude: _double(checkIn?["longitude"]),
      selfie: checkIn?["selfie"] ?? "",
      place: checkIn?["place"] ?? "",
      city: checkIn?["city"] ?? "",
      state: checkIn?["state"] ?? "",
      country: checkIn?["country"] ?? "",
      totalDistanceKm: _double(json["totalDistanceKm"]),
      workingMinutes: json["workingMinutes"] ?? 0,
      user: rawUser is Map<String, dynamic>
          ? UserSummary.fromJson(rawUser)
          : null,
    );
  }

  String get workingHourText {
    final h = workingMinutes ~/ 60;
    final m = workingMinutes % 60;

    return "${h}h ${m}m";
  }

  String get address => [
    place,
    city,
    state,
    country,
  ].where((part) => part.trim().isNotEmpty).join(", ");

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString())?.toLocal();

  static double _double(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? "") ?? 0;
  }
}

class UserSummary {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;

  UserSummary({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json["_id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      email: json["email"]?.toString() ?? "",
      phone: json["phone"]?.toString() ?? "",
      profileImage: json["profileImage"]?.toString() ?? "",
    );
  }
}
