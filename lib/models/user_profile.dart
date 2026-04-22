class UserProfile {
  final String id;
  final String fullName;
  final String heightCm;
  final String weightKg;
  final String nationality;
  final String country;
  final String city;
  final String car;
  final String? photoUrl;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.heightCm,
    required this.weightKg,
    required this.nationality,
    required this.country,
    required this.city,
    required this.car,
    this.photoUrl,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      heightCm: json['height_cm'] ?? '',
      weightKg: json['weight_kg'] ?? '',
      nationality: json['nationality'] ?? '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      car: json['car'] ?? 'Other',
      photoUrl: json['photo_url'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'nationality': nationality,
      'country': country,
      'city': city,
      'car': car,
      'photo_url': photoUrl,
    };
  }
}
