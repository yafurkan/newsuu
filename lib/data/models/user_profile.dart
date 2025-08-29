import 'package:cloud_firestore/cloud_firestore.dart';

/// Cinsiyet enum'u - App Store uyumlu
enum Gender { 
  male, 
  female, 
  undisclosed;
  
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Erkek';
      case Gender.female:
        return 'Kadın';
      case Gender.undisclosed:
        return 'Belirtmek istemiyorum';
    }
  }
}

/// Aktivite seviyesi enum'u
enum ActivityLevel { 
  low, 
  medium, 
  high;
  
  String get displayName {
    switch (this) {
      case ActivityLevel.low:
        return 'Düşük (Masa başı)';
      case ActivityLevel.medium:
        return 'Orta (Aktif iş / haftada 1-3 gün spor)';
      case ActivityLevel.high:
        return 'Yüksek (Ağır iş / haftada 3+ gün spor)';
    }
  }
  
  String get description {
    switch (this) {
      case ActivityLevel.low:
        return 'Az hareket';
      case ActivityLevel.medium:
        return 'Haftada 1-3 gün spor';
      case ActivityLevel.high:
        return 'Haftada 3+ gün spor';
    }
  }
}

/// Sebze ve meyve tüketim sıklığı
enum VeggieFreq { 
  rare, 
  daily, 
  frequent;
  
  String get displayName {
    switch (this) {
      case VeggieFreq.rare:
        return 'Nadiren';
      case VeggieFreq.daily:
        return 'Düzenli olarak';
      case VeggieFreq.frequent:
        return 'Sıklıkla';
    }
  }
  
  String get description {
    switch (this) {
      case VeggieFreq.rare:
        return 'Haftada birkaç kez';
      case VeggieFreq.daily:
        return 'Her gün';
      case VeggieFreq.frequent:
        return 'Günde birkaç kez';
    }
  }
}

/// Şekerli içecek tüketim sıklığı
enum SugaryFreq { 
  almostNever, 
  rare, 
  daily, 
  frequent;
  
  String get displayName {
    switch (this) {
      case SugaryFreq.almostNever:
        return 'Neredeyse hiç';
      case SugaryFreq.rare:
        return 'Nadiren';
      case SugaryFreq.daily:
        return 'Düzenli olarak';
      case SugaryFreq.frequent:
        return 'Sıklıkla';
    }
  }
  
  String get description {
    switch (this) {
      case SugaryFreq.almostNever:
        return 'Hiç/ayda birkaç';
      case SugaryFreq.rare:
        return 'Haftada birkaç';
      case SugaryFreq.daily:
        return 'Her gün';
      case SugaryFreq.frequent:
        return 'Günde birkaç kez';
    }
  }
}

/// Genişletilmiş kullanıcı profil modeli
class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final int age;
  final double weightKg;        // Her zaman KG olarak sakla
  final double heightCm;        // Her zaman CM olarak sakla
  final Gender gender;
  final ActivityLevel activity;
  final Set<String> goals;      // Hedef ID'leri
  final VeggieFreq veggies;
  final SugaryFreq sugary;
  final String? unitPreferenceWeight; // "kg"|"lb" (UI için)
  final String? unitPreferenceHeight; // "cm"|"ft_in"
  final double dailyGoalMl;
  final bool isFirstTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String profileImageUrl;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> statistics;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.gender,
    required this.activity,
    this.goals = const {},
    this.veggies = VeggieFreq.rare,
    this.sugary = SugaryFreq.almostNever,
    this.unitPreferenceWeight,
    this.unitPreferenceHeight,
    required this.dailyGoalMl,
    this.isFirstTime = false,
    required this.createdAt,
    required this.updatedAt,
    this.profileImageUrl = '',
    this.preferences = const {},
    this.statistics = const {},
  });

  /// Factory constructor - Firebase Firestore'dan veri alırken kullanılır
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 25,
      weightKg: (json['weightKg'] ?? 70.0).toDouble(),
      heightCm: (json['heightCm'] ?? 170.0).toDouble(),
      gender: Gender.values.firstWhere(
        (g) => g.name == json['gender'],
        orElse: () => Gender.undisclosed,
      ),
      activity: ActivityLevel.values.firstWhere(
        (a) => a.name == json['activity'],
        orElse: () => ActivityLevel.medium,
      ),
      goals: Set<String>.from(json['goals'] ?? []),
      veggies: VeggieFreq.values.firstWhere(
        (v) => v.name == json['veggies'],
        orElse: () => VeggieFreq.rare,
      ),
      sugary: SugaryFreq.values.firstWhere(
        (s) => s.name == json['sugary'],
        orElse: () => SugaryFreq.almostNever,
      ),
      unitPreferenceWeight: json['unitPreferenceWeight'],
      unitPreferenceHeight: json['unitPreferenceHeight'],
      dailyGoalMl: (json['dailyGoalMl'] ?? 2000.0).toDouble(),
      isFirstTime: json['isFirstTime'] ?? false,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      profileImageUrl: json['profileImageUrl'] ?? '',
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      statistics: Map<String, dynamic>.from(json['statistics'] ?? {}),
    );
  }

  /// Firebase Firestore'a kaydetmek için JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'age': age,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'gender': gender.name,
      'activity': activity.name,
      'goals': goals.toList(),
      'veggies': veggies.name,
      'sugary': sugary.name,
      'unitPreferenceWeight': unitPreferenceWeight,
      'unitPreferenceHeight': unitPreferenceHeight,
      'dailyGoalMl': dailyGoalMl,
      'isFirstTime': isFirstTime,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'profileImageUrl': profileImageUrl,
      'preferences': preferences,
      'statistics': statistics,
    };
  }

  /// Varsayılan kullanıcı profili oluşturma
  factory UserProfile.defaultProfile() {
    return UserProfile(
      id: '',
      firstName: '',
      lastName: '',
      email: '',
      age: 25,
      weightKg: 70.0,
      heightCm: 170.0,
      gender: Gender.undisclosed,
      activity: ActivityLevel.medium,
      goals: {},
      veggies: VeggieFreq.rare,
      sugary: SugaryFreq.almostNever,
      unitPreferenceWeight: 'kg',
      unitPreferenceHeight: 'cm',
      dailyGoalMl: 2000.0,
      isFirstTime: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Profili kopyalama (immutable)
  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    int? age,
    double? weightKg,
    double? heightCm,
    Gender? gender,
    ActivityLevel? activity,
    Set<String>? goals,
    VeggieFreq? veggies,
    SugaryFreq? sugary,
    String? unitPreferenceWeight,
    String? unitPreferenceHeight,
    double? dailyGoalMl,
    bool? isFirstTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? statistics,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      gender: gender ?? this.gender,
      activity: activity ?? this.activity,
      goals: goals ?? this.goals,
      veggies: veggies ?? this.veggies,
      sugary: sugary ?? this.sugary,
      unitPreferenceWeight: unitPreferenceWeight ?? this.unitPreferenceWeight,
      unitPreferenceHeight: unitPreferenceHeight ?? this.unitPreferenceHeight,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
      statistics: statistics ?? this.statistics,
    );
  }

  /// Tam isim
  String get fullName => '$firstName $lastName'.trim();

  /// BMI hesaplama
  double get bmi {
    if (heightCm <= 0 || weightKg <= 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $fullName, dailyGoalMl: $dailyGoalMl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
