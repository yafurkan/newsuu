import 'package:cloud_firestore/cloud_firestore.dart';

/// Rozet modeli - Firebase Firestore ile uyumlu
class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String iconPath;
  final String funFact;
  final int requiredValue;
  final String requiredAction;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int rarity; // 1: Yaygın, 2: Nadir, 3: Efsane, 4: Mitik
  final List<String> colors; // Gradient renkleri

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconPath,
    required this.funFact,
    required this.requiredValue,
    required this.requiredAction,
    this.isUnlocked = false,
    this.unlockedAt,
    this.rarity = 1,
    this.colors = const ['#4A90E2', '#50E3C2'],
  });

  /// Factory constructor - Firebase Firestore'dan veri alırken kullanılır
  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      iconPath: json['iconPath'] ?? '',
      funFact: json['funFact'] ?? '',
      requiredValue: json['requiredValue'] ?? 0,
      requiredAction: json['requiredAction'] ?? '',
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? (json['unlockedAt'] as Timestamp).toDate()
          : null,
      rarity: json['rarity'] ?? 1,
      colors: List<String>.from(json['colors'] ?? ['#4A90E2', '#50E3C2']),
    );
  }

  /// Firebase Firestore'a kaydetmek için JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'iconPath': iconPath,
      'funFact': funFact,
      'requiredValue': requiredValue,
      'requiredAction': requiredAction,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null
          ? Timestamp.fromDate(unlockedAt!)
          : null,
      'rarity': rarity,
      'colors': colors,
    };
  }

  /// Rozeti kopyalama (immutable)
  BadgeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? iconPath,
    String? funFact,
    int? requiredValue,
    String? requiredAction,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? rarity,
    List<String>? colors,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      iconPath: iconPath ?? this.iconPath,
      funFact: funFact ?? this.funFact,
      requiredValue: requiredValue ?? this.requiredValue,
      requiredAction: requiredAction ?? this.requiredAction,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rarity: rarity ?? this.rarity,
      colors: colors ?? this.colors,
    );
  }

  /// Rozeti kilitle
  BadgeModel unlock() {
    return copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );
  }

  /// Nadir seviye metni
  String get rarityText {
    switch (rarity) {
      case 1:
        return 'Yaygın';
      case 2:
        return 'Nadir';
      case 3:
        return 'Efsane';
      case 4:
        return 'Mitik';
      default:
        return 'Yaygın';
    }
  }

  /// Nadir seviye rengi
  String get rarityColor {
    switch (rarity) {
      case 1:
        return '#4A90E2'; // Mavi
      case 2:
        return '#7ED321'; // Yeşil
      case 3:
        return '#F5A623'; // Altın
      case 4:
        return '#D0021B'; // Kırmızı
      default:
        return '#4A90E2';
    }
  }

  @override
  String toString() {
    return 'BadgeModel(id: $id, name: $name, isUnlocked: $isUnlocked)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BadgeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Kullanıcı rozet istatistikleri
class UserBadgeStats {
  final int totalBadges;
  final int unlockedBadges;
  final int commonBadges;
  final int rareBadges;
  final int legendaryBadges;
  final int mythicBadges;
  final DateTime? lastUnlockedAt;
  final String? lastUnlockedBadgeId;

  UserBadgeStats({
    this.totalBadges = 0,
    this.unlockedBadges = 0,
    this.commonBadges = 0,
    this.rareBadges = 0,
    this.legendaryBadges = 0,
    this.mythicBadges = 0,
    this.lastUnlockedAt,
    this.lastUnlockedBadgeId,
  });

  factory UserBadgeStats.fromJson(Map<String, dynamic> json) {
    return UserBadgeStats(
      totalBadges: json['totalBadges'] ?? 0,
      unlockedBadges: json['unlockedBadges'] ?? 0,
      commonBadges: json['commonBadges'] ?? 0,
      rareBadges: json['rareBadges'] ?? 0,
      legendaryBadges: json['legendaryBadges'] ?? 0,
      mythicBadges: json['mythicBadges'] ?? 0,
      lastUnlockedAt: json['lastUnlockedAt'] != null
          ? (json['lastUnlockedAt'] as Timestamp).toDate()
          : null,
      lastUnlockedBadgeId: json['lastUnlockedBadgeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBadges': totalBadges,
      'unlockedBadges': unlockedBadges,
      'commonBadges': commonBadges,
      'rareBadges': rareBadges,
      'legendaryBadges': legendaryBadges,
      'mythicBadges': mythicBadges,
      'lastUnlockedAt': lastUnlockedAt != null
          ? Timestamp.fromDate(lastUnlockedAt!)
          : null,
      'lastUnlockedBadgeId': lastUnlockedBadgeId,
    };
  }

  /// Tamamlanma yüzdesi
  double get completionPercentage {
    if (totalBadges == 0) return 0.0;
    return (unlockedBadges / totalBadges) * 100;
  }

  UserBadgeStats copyWith({
    int? totalBadges,
    int? unlockedBadges,
    int? commonBadges,
    int? rareBadges,
    int? legendaryBadges,
    int? mythicBadges,
    DateTime? lastUnlockedAt,
    String? lastUnlockedBadgeId,
  }) {
    return UserBadgeStats(
      totalBadges: totalBadges ?? this.totalBadges,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      commonBadges: commonBadges ?? this.commonBadges,
      rareBadges: rareBadges ?? this.rareBadges,
      legendaryBadges: legendaryBadges ?? this.legendaryBadges,
      mythicBadges: mythicBadges ?? this.mythicBadges,
      lastUnlockedAt: lastUnlockedAt ?? this.lastUnlockedAt,
      lastUnlockedBadgeId: lastUnlockedBadgeId ?? this.lastUnlockedBadgeId,
    );
  }
}