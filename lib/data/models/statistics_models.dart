class WaterEntry {
  final double amount;
  final DateTime timestamp;
  final String type; // 'add' veya 'remove'
  final String source; // 'quick_button', 'manual', 'preset'

  WaterEntry({
    required this.amount,
    required this.timestamp,
    required this.type,
    required this.source,
  });

  factory WaterEntry.fromJson(Map<String, dynamic> json) {
    return WaterEntry(
      amount: (json['amount'] ?? 0).toDouble(),
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      type: json['type'] ?? 'add',
      source: json['source'] ?? 'manual',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'source': source,
    };
  }
}

class DailyStats {
  final String date; // yyyy-MM-dd format
  final double totalWater; // Toplam su tüketimi
  final double goalWater; // O günkü hedef
  final int addCount; // Kaç kez su eklendi
  final int removeCount; // Kaç kez su çıkarıldı
  final double achievementPercentage; // Hedefe ulaşma yüzdesi
  final List<WaterEntry> entries; // Detaylı su giriş listesi
  final DateTime createdAt;

  DailyStats({
    required this.date,
    required this.totalWater,
    required this.goalWater,
    required this.addCount,
    required this.removeCount,
    required this.achievementPercentage,
    required this.entries,
    required this.createdAt,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: json['date'] ?? '',
      totalWater: (json['totalWater'] ?? 0).toDouble(),
      goalWater: (json['goalWater'] ?? 0).toDouble(),
      addCount: json['addCount'] ?? 0,
      removeCount: json['removeCount'] ?? 0,
      achievementPercentage: (json['achievementPercentage'] ?? 0).toDouble(),
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map((e) => WaterEntry.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'totalWater': totalWater,
      'goalWater': goalWater,
      'addCount': addCount,
      'removeCount': removeCount,
      'achievementPercentage': achievementPercentage,
      'entries': entries.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class WeeklyStats {
  final String weekStart; // yyyy-MM-dd format (pazartesi)
  final String weekEnd; // yyyy-MM-dd format (pazar)
  final double totalWater;
  final double averageDaily;
  final double goalAchievementRate; // Haftalık hedef başarı oranı
  final int bestDay; // En iyi gün (1-7, pazartesi=1)
  final int worstDay; // En kötü gün
  final List<DailyStats> dailyStats;
  final DateTime createdAt;

  WeeklyStats({
    required this.weekStart,
    required this.weekEnd,
    required this.totalWater,
    required this.averageDaily,
    required this.goalAchievementRate,
    required this.bestDay,
    required this.worstDay,
    required this.dailyStats,
    required this.createdAt,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    return WeeklyStats(
      weekStart: json['weekStart'] ?? '',
      weekEnd: json['weekEnd'] ?? '',
      totalWater: (json['totalWater'] ?? 0).toDouble(),
      averageDaily: (json['averageDaily'] ?? 0).toDouble(),
      goalAchievementRate: (json['goalAchievementRate'] ?? 0).toDouble(),
      bestDay: json['bestDay'] ?? 1,
      worstDay: json['worstDay'] ?? 1,
      dailyStats:
          (json['dailyStats'] as List<dynamic>?)
              ?.map((e) => DailyStats.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekStart': weekStart,
      'weekEnd': weekEnd,
      'totalWater': totalWater,
      'averageDaily': averageDaily,
      'goalAchievementRate': goalAchievementRate,
      'bestDay': bestDay,
      'worstDay': worstDay,
      'dailyStats': dailyStats.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class MonthlyStats {
  final String month; // yyyy-MM format
  final double totalWater;
  final double averageDaily;
  final double goalAchievementRate;
  final int perfectDays; // Hedefe %100 ulaşılan günler
  final int goodDays; // Hedefe %75+ ulaşılan günler
  final int badDays; // Hedefe %50- ulaşılan günler
  final double bestDayAmount;
  final double worstDayAmount;
  final List<WeeklyStats> weeklyStats;
  final DateTime createdAt;

  MonthlyStats({
    required this.month,
    required this.totalWater,
    required this.averageDaily,
    required this.goalAchievementRate,
    required this.perfectDays,
    required this.goodDays,
    required this.badDays,
    required this.bestDayAmount,
    required this.worstDayAmount,
    required this.weeklyStats,
    required this.createdAt,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    return MonthlyStats(
      month: json['month'] ?? '',
      totalWater: (json['totalWater'] ?? 0).toDouble(),
      averageDaily: (json['averageDaily'] ?? 0).toDouble(),
      goalAchievementRate: (json['goalAchievementRate'] ?? 0).toDouble(),
      perfectDays: json['perfectDays'] ?? 0,
      goodDays: json['goodDays'] ?? 0,
      badDays: json['badDays'] ?? 0,
      bestDayAmount: (json['bestDayAmount'] ?? 0).toDouble(),
      worstDayAmount: (json['worstDayAmount'] ?? 0).toDouble(),
      weeklyStats:
          (json['weeklyStats'] as List<dynamic>?)
              ?.map((e) => WeeklyStats.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'totalWater': totalWater,
      'averageDaily': averageDaily,
      'goalAchievementRate': goalAchievementRate,
      'perfectDays': perfectDays,
      'goodDays': goodDays,
      'badDays': badDays,
      'bestDayAmount': bestDayAmount,
      'worstDayAmount': worstDayAmount,
      'weeklyStats': weeklyStats.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class PerformanceMetrics {
  final String userId;
  final double currentWeight;
  final double currentHeight;
  final int currentAge;
  final String currentGender;
  final String currentActivityLevel;
  final double currentGoal;
  final double
  idealIntakeForProfile; // Profil bilgilerine göre ideal su miktarı
  final double personalBest; // Kişisel en iyi günlük rekoru
  final int streakDays; // Ardışık hedef tutan günler
  final int totalDaysTracked; // Toplam takip edilen gün sayısı
  final DateTime profileLastUpdated; // Profil son güncellenme tarihi
  final DateTime createdAt;

  PerformanceMetrics({
    required this.userId,
    required this.currentWeight,
    required this.currentHeight,
    required this.currentAge,
    required this.currentGender,
    required this.currentActivityLevel,
    required this.currentGoal,
    required this.idealIntakeForProfile,
    required this.personalBest,
    required this.streakDays,
    required this.totalDaysTracked,
    required this.profileLastUpdated,
    required this.createdAt,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      userId: json['userId'] ?? '',
      currentWeight: (json['currentWeight'] ?? 0).toDouble(),
      currentHeight: (json['currentHeight'] ?? 0).toDouble(),
      currentAge: json['currentAge'] ?? 0,
      currentGender: json['currentGender'] ?? '',
      currentActivityLevel: json['currentActivityLevel'] ?? '',
      currentGoal: (json['currentGoal'] ?? 0).toDouble(),
      idealIntakeForProfile: (json['idealIntakeForProfile'] ?? 0).toDouble(),
      personalBest: (json['personalBest'] ?? 0).toDouble(),
      streakDays: json['streakDays'] ?? 0,
      totalDaysTracked: json['totalDaysTracked'] ?? 0,
      profileLastUpdated: DateTime.parse(
        json['profileLastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentWeight': currentWeight,
      'currentHeight': currentHeight,
      'currentAge': currentAge,
      'currentGender': currentGender,
      'currentActivityLevel': currentActivityLevel,
      'currentGoal': currentGoal,
      'idealIntakeForProfile': idealIntakeForProfile,
      'personalBest': personalBest,
      'streakDays': streakDays,
      'totalDaysTracked': totalDaysTracked,
      'profileLastUpdated': profileLastUpdated.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
