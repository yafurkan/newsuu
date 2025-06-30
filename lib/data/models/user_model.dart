import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// Kullanıcı bilgilerini tutan model sınıfı
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String firstName;

  @HiveField(1)
  String lastName;

  @HiveField(2)
  int age;

  @HiveField(3)
  double weight; // kg

  @HiveField(4)
  double height; // cm

  @HiveField(5)
  String gender; // 'male' or 'female'

  @HiveField(6)
  String activityLevel; // 'low', 'medium', 'high'

  @HiveField(7)
  double dailyWaterGoal; // ml

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  @HiveField(10)
  bool isFirstTime; // Onboarding tamamlandı mı?

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.activityLevel,
    required this.dailyWaterGoal,
    required this.createdAt,
    required this.updatedAt,
    this.isFirstTime = true,
  });

  /// Kullanıcının tam adını döndürür
  String get fullName => '$firstName $lastName';

  /// BMI hesaplar
  double get bmi {
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// BMI kategorisini döndürür
  String get bmiCategory {
    if (bmi < 18.5) return 'Zayıf';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Fazla Kilolu';
    return 'Obez';
  }

  /// JSON'a çevirir
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'activityLevel': activityLevel,
      'dailyWaterGoal': dailyWaterGoal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFirstTime': isFirstTime,
    };
  }

  /// JSON'dan oluşturur
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      age: json['age'] ?? 0,
      weight: (json['weight'] ?? 0.0).toDouble(),
      height: (json['height'] ?? 0.0).toDouble(),
      gender: json['gender'] ?? 'male',
      activityLevel: json['activityLevel'] ?? 'medium',
      dailyWaterGoal: (json['dailyWaterGoal'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      isFirstTime: json['isFirstTime'] ?? true,
    );
  }

  /// Kullanıcı bilgilerini günceller
  UserModel copyWith({
    String? firstName,
    String? lastName,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? activityLevel,
    double? dailyWaterGoal,
    DateTime? updatedAt,
    bool? isFirstTime,
  }) {
    return UserModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      dailyWaterGoal: dailyWaterGoal ?? this.dailyWaterGoal,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }

  @override
  String toString() {
    return 'UserModel(firstName: $firstName, lastName: $lastName, age: $age, weight: $weight, height: $height, gender: $gender, activityLevel: $activityLevel, dailyWaterGoal: $dailyWaterGoal)';
  }
}
