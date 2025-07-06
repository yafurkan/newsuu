import 'package:cloud_firestore/cloud_firestore.dart';

/// Kullanıcı modeli - Firebase Firestore ile uyumlu
class UserModel {
  final String id;
  final String name;
  final String email;
  final int age;
  final double weight;
  final String activityLevel;
  final double dailyWaterGoal;
  final bool isFirstTime;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String profileImageUrl;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> statistics;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.weight,
    required this.activityLevel,
    required this.dailyWaterGoal,
    this.isFirstTime = false,
    required this.createdAt,
    this.lastLoginAt,
    this.profileImageUrl = '',
    this.preferences = const {},
    this.statistics = const {},
  });

  /// Factory constructor - Firebase Firestore'dan veri alırken kullanılır
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 25,
      weight: (json['weight'] ?? 70.0).toDouble(),
      activityLevel: json['activityLevel'] ?? 'moderate',
      dailyWaterGoal: (json['dailyWaterGoal'] ?? 2000.0).toDouble(),
      isFirstTime: json['isFirstTime'] ?? false,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? (json['lastLoginAt'] as Timestamp).toDate()
          : null,
      profileImageUrl: json['profileImageUrl'] ?? '',
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      statistics: Map<String, dynamic>.from(json['statistics'] ?? {}),
    );
  }

  /// Firebase Firestore'a kaydetmek için JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'weight': weight,
      'activityLevel': activityLevel,
      'dailyWaterGoal': dailyWaterGoal,
      'isFirstTime': isFirstTime,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null
          ? Timestamp.fromDate(lastLoginAt!)
          : null,
      'profileImageUrl': profileImageUrl,
      'preferences': preferences,
      'statistics': statistics,
    };
  }

  /// Varsayılan kullanıcı oluşturma
  factory UserModel.defaultUser() {
    return UserModel(
      id: '',
      name: 'Kullanıcı',
      email: '',
      age: 25,
      weight: 70.0,
      activityLevel: 'moderate',
      dailyWaterGoal: 2000.0,
      isFirstTime: true,
      createdAt: DateTime.now(),
    );
  }

  /// Kullanıcı modelini kopyalama (immutable)
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    double? weight,
    String? activityLevel,
    double? dailyWaterGoal,
    bool? isFirstTime,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? statistics,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      dailyWaterGoal: dailyWaterGoal ?? this.dailyWaterGoal,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
      statistics: statistics ?? this.statistics,
    );
  }

  /// Kullanıcı bilgilerini güncelleme
  UserModel updateProfile({
    String? name,
    int? age,
    double? weight,
    String? activityLevel,
    double? dailyWaterGoal,
    String? profileImageUrl,
  }) {
    return copyWith(
      name: name,
      age: age,
      weight: weight,
      activityLevel: activityLevel,
      dailyWaterGoal: dailyWaterGoal,
      profileImageUrl: profileImageUrl,
      isFirstTime: false,
    );
  }

  /// İlk kez giriş yapan kullanıcıyı güncelleme
  UserModel completeOnboarding() {
    return copyWith(isFirstTime: false);
  }

  /// Son giriş zamanını güncelleme
  UserModel updateLastLogin() {
    return copyWith(lastLoginAt: DateTime.now());
  }

  /// Günlük su ihtiyacını hesaplama
  static double calculateDailyWaterNeed({
    required double weight,
    required int age,
    required String activityLevel,
    required String gender,
  }) {
    double baseWater = weight * 35; // ml

    // Yaş faktörü
    if (age > 65) {
      baseWater *= 0.95;
    } else if (age < 18) {
      baseWater *= 1.1;
    }

    // Cinsiyet faktörü
    if (gender == 'male') {
      baseWater *= 1.05;
    } else {
      baseWater *= 0.95;
    }

    // Aktivite seviyesi faktörü
    switch (activityLevel) {
      case 'low':
        baseWater *= 1.0;
        break;
      case 'moderate':
        baseWater *= 1.1;
        break;
      case 'high':
        baseWater *= 1.2;
        break;
      case 'very_high':
        baseWater *= 1.3;
        break;
      default:
        baseWater *= 1.0;
    }

    return baseWater.round().toDouble();
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, dailyWaterGoal: $dailyWaterGoal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
