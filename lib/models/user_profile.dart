enum ActivityMode { personal, driving, biking, shipping, walking, hiking }
enum Industry { transport, maritime, aviation, recycling, energy, agriculture, other }
enum EngineSize { electric, hybrid, l1_0, l1_2, l1_4, l1_6, l2_0, l2_5, l3_0plus }

class UserProfile {
  final String id;
  final String fullName;
  final String heightCm;
  final String weightKg;
  final String country;
  final String city;
  final String carEngineSize;
  final String industry;
  final String activityMode;
  final String? photoUri;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.heightCm,
    required this.weightKg,
    required this.country,
    required this.city,
    required this.carEngineSize,
    required this.industry,
    required this.activityMode,
    this.photoUri,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      heightCm: json['height_cm'] ?? '',
      weightKg: json['weight_kg'] ?? '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      carEngineSize: json['car_engine_size'] ?? '1.0L',
      industry: json['industry'] ?? 'Other',
      activityMode: json['activity_mode'] ?? 'personal',
      photoUri: json['photo_uri'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'country': country,
      'city': city,
      'car_engine_size': carEngineSize,
      'industry': industry,
      'activity_mode': activityMode,
      'photo_uri': photoUri,
    };
  }
}
