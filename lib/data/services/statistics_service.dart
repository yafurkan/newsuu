import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/statistics_models.dart';
import '../../core/utils/debug_logger.dart';

class StatisticsService {
  static final StatisticsService _instance = StatisticsService._internal();
  factory StatisticsService() => _instance;
  StatisticsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Günlük istatistik kaydet
  Future<void> saveDailyStats(DailyStats dailyStats) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_stats')
          .doc(dailyStats.date)
          .set(dailyStats.toJson());

      DebugLogger.success(
        'Günlük istatistik kaydedildi: ${dailyStats.date}',
        tag: 'STATISTICS',
      );
    } catch (e) {
      DebugLogger.error(
        'Günlük istatistik kaydetme hatası: $e',
        tag: 'STATISTICS',
      );
      rethrow;
    }
  }

  /// Belirli bir günün istatistiklerini al
  Future<DailyStats?> getDailyStats(String date) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_stats')
          .doc(date)
          .get();

      if (doc.exists) {
        return DailyStats.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      DebugLogger.error('Günlük istatistik alma hatası: $e', tag: 'STATISTICS');
      return null;
    }
  }

  /// Haftalık istatistikleri hesapla ve al
  Future<WeeklyStats?> getWeeklyStats(DateTime weekStart) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Haftanın 7 gününün istatistiklerini al
      List<DailyStats> dailyStatsList = [];
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final dateStr = _formatDate(date);
        final dailyStats = await getDailyStats(dateStr);
        if (dailyStats != null) {
          dailyStatsList.add(dailyStats);
        }
      }

      if (dailyStatsList.isEmpty) return null;

      // Haftalık istatistikleri hesapla
      final totalWater = dailyStatsList.fold<double>(
        0.0,
        (total, stats) => total + stats.totalWater,
      );
      final averageDaily = totalWater / 7;
      final goalAchievementRate =
          dailyStatsList.fold<double>(
            0.0,
            (total, stats) => total + stats.achievementPercentage,
          ) /
          dailyStatsList.length;

      // En iyi ve en kötü günü bul
      int bestDay = 1;
      int worstDay = 1;
      double bestAmount = 0;
      double worstAmount = double.infinity;

      for (int i = 0; i < dailyStatsList.length; i++) {
        final stats = dailyStatsList[i];
        if (stats.totalWater > bestAmount) {
          bestAmount = stats.totalWater;
          bestDay = i + 1;
        }
        if (stats.totalWater < worstAmount) {
          worstAmount = stats.totalWater;
          worstDay = i + 1;
        }
      }

      return WeeklyStats(
        weekStart: _formatDate(weekStart),
        weekEnd: _formatDate(weekStart.add(const Duration(days: 6))),
        totalWater: totalWater,
        averageDaily: averageDaily,
        goalAchievementRate: goalAchievementRate,
        bestDay: bestDay,
        worstDay: worstDay,
        dailyStats: dailyStatsList,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      DebugLogger.error(
        'Haftalık istatistik hesaplama hatası: $e',
        tag: 'STATISTICS',
      );
      return null;
    }
  }

  /// Aylık istatistikleri hesapla ve al
  Future<MonthlyStats?> getMonthlyStats(DateTime month) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Ayın tüm günlerinin istatistiklerini al
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      List<DailyStats> dailyStatsList = [];
      List<WeeklyStats> weeklyStatsList = [];

      // Günlük istatistikleri topla
      for (int day = 1; day <= lastDay.day; day++) {
        final date = DateTime(month.year, month.month, day);
        final dateStr = _formatDate(date);
        final dailyStats = await getDailyStats(dateStr);
        if (dailyStats != null) {
          dailyStatsList.add(dailyStats);
        }
      }

      if (dailyStatsList.isEmpty) return null;

      // Haftalık istatistikleri hesapla
      DateTime weekStart = _getWeekStart(firstDay);
      while (weekStart.isBefore(lastDay) ||
          weekStart.isAtSameMomentAs(lastDay)) {
        final weekStats = await getWeeklyStats(weekStart);
        if (weekStats != null) {
          weeklyStatsList.add(weekStats);
        }
        weekStart = weekStart.add(const Duration(days: 7));
      }

      // Aylık metrikleri hesapla
      final totalWater = dailyStatsList.fold<double>(
        0.0,
        (total, stats) => total + stats.totalWater,
      );
      final averageDaily = totalWater / lastDay.day;
      final goalAchievementRate =
          dailyStatsList.fold<double>(
            0.0,
            (total, stats) => total + stats.achievementPercentage,
          ) /
          dailyStatsList.length;

      int perfectDays = 0;
      int goodDays = 0;
      int badDays = 0;
      double bestDayAmount = 0;
      double worstDayAmount = double.infinity;

      for (final stats in dailyStatsList) {
        if (stats.achievementPercentage >= 100) {
          perfectDays++;
        } else if (stats.achievementPercentage >= 75) {
          goodDays++;
        } else if (stats.achievementPercentage < 50) {
          badDays++;
        }

        if (stats.totalWater > bestDayAmount) {
          bestDayAmount = stats.totalWater;
        }
        if (stats.totalWater < worstDayAmount) {
          worstDayAmount = stats.totalWater;
        }
      }

      return MonthlyStats(
        month: '${month.year}-${month.month.toString().padLeft(2, '0')}',
        totalWater: totalWater,
        averageDaily: averageDaily,
        goalAchievementRate: goalAchievementRate,
        perfectDays: perfectDays,
        goodDays: goodDays,
        badDays: badDays,
        bestDayAmount: bestDayAmount,
        worstDayAmount: worstDayAmount == double.infinity ? 0 : worstDayAmount,
        weeklyStats: weeklyStatsList,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      DebugLogger.error(
        'Aylık istatistik hesaplama hatası: $e',
        tag: 'STATISTICS',
      );
      return null;
    }
  }

  /// Performans metriklerini kaydet
  Future<void> savePerformanceMetrics(PerformanceMetrics metrics) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('performance_metrics')
          .doc('current')
          .set(metrics.toJson());

      DebugLogger.success(
        'Performans metrikleri kaydedildi',
        tag: 'STATISTICS',
      );
    } catch (e) {
      DebugLogger.error(
        'Performans metrikleri kaydetme hatası: $e',
        tag: 'STATISTICS',
      );
      rethrow;
    }
  }

  /// Performans metriklerini al
  Future<PerformanceMetrics?> getPerformanceMetrics() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('performance_metrics')
          .doc('current')
          .get();

      if (doc.exists) {
        return PerformanceMetrics.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      DebugLogger.error(
        'Performans metrikleri alma hatası: $e',
        tag: 'STATISTICS',
      );
      return null;
    }
  }

  /// Tarih aralığındaki günlük istatistikleri al
  Future<List<DailyStats>> getDailyStatsRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final startStr = _formatDate(start);
      final endStr = _formatDate(end);

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_stats')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startStr)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endStr)
          .orderBy(FieldPath.documentId)
          .get();

      return querySnapshot.docs
          .map((doc) => DailyStats.fromJson(doc.data()))
          .toList();
    } catch (e) {
      DebugLogger.error(
        'Tarih aralığı istatistik alma hatası: $e',
        tag: 'STATISTICS',
      );
      return [];
    }
  }

  /// Kişisel rekorları güncelle
  Future<void> updatePersonalBest(double amount) async {
    try {
      final metrics = await getPerformanceMetrics();
      if (metrics != null && amount > metrics.personalBest) {
        final updatedMetrics = PerformanceMetrics(
          userId: metrics.userId,
          currentWeight: metrics.currentWeight,
          currentHeight: metrics.currentHeight,
          currentAge: metrics.currentAge,
          currentGender: metrics.currentGender,
          currentActivityLevel: metrics.currentActivityLevel,
          currentGoal: metrics.currentGoal,
          idealIntakeForProfile: metrics.idealIntakeForProfile,
          personalBest: amount,
          streakDays: metrics.streakDays,
          totalDaysTracked: metrics.totalDaysTracked,
          profileLastUpdated: metrics.profileLastUpdated,
          createdAt: metrics.createdAt,
        );

        await savePerformanceMetrics(updatedMetrics);

        DebugLogger.success(
          'Kişisel rekoru güncellendi: ${amount}ml',
          tag: 'STATISTICS',
        );
      }
    } catch (e) {
      DebugLogger.error(
        'Kişisel rekoru güncelleme hatası: $e',
        tag: 'STATISTICS',
      );
    }
  }

  /// Streak günlerini güncelle
  Future<void> updateStreakDays() async {
    try {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      final todayStats = await getDailyStats(_formatDate(today));
      final yesterdayStats = await getDailyStats(_formatDate(yesterday));

      final metrics = await getPerformanceMetrics();
      if (metrics == null) return;

      int newStreakDays = metrics.streakDays;

      // Bugün hedef tutturulduysa
      if (todayStats != null && todayStats.achievementPercentage >= 100) {
        // Dün de tutturulduysa streak devam ediyor
        if (yesterdayStats != null &&
            yesterdayStats.achievementPercentage >= 100) {
          newStreakDays = metrics.streakDays + 1;
        } else {
          // Yeni streak başlıyor
          newStreakDays = 1;
        }
      } else {
        // Bugün tutturulamadıysa streak sıfırlanıyor
        newStreakDays = 0;
      }

      if (newStreakDays != metrics.streakDays) {
        final updatedMetrics = PerformanceMetrics(
          userId: metrics.userId,
          currentWeight: metrics.currentWeight,
          currentHeight: metrics.currentHeight,
          currentAge: metrics.currentAge,
          currentGender: metrics.currentGender,
          currentActivityLevel: metrics.currentActivityLevel,
          currentGoal: metrics.currentGoal,
          idealIntakeForProfile: metrics.idealIntakeForProfile,
          personalBest: metrics.personalBest,
          streakDays: newStreakDays,
          totalDaysTracked: metrics.totalDaysTracked + 1,
          profileLastUpdated: metrics.profileLastUpdated,
          createdAt: metrics.createdAt,
        );

        await savePerformanceMetrics(updatedMetrics);
      }
    } catch (e) {
      DebugLogger.error(
        'Streak günleri güncelleme hatası: $e',
        tag: 'STATISTICS',
      );
    }
  }

  /// Su girişi ekle ve günlük istatistikleri güncelle
  Future<void> addWaterEntry({
    required double amount,
    required String type, // 'add' veya 'remove'
    required String source,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      final now = DateTime.now();
      final dateStr = _formatDate(now);

      // Yeni su girişi oluştur
      final waterEntry = WaterEntry(
        amount: amount,
        timestamp: now,
        type: type,
        source: source,
      );

      // Bugünkü istatistikleri al veya oluştur
      DailyStats? todayStats = await getDailyStats(dateStr);

      if (todayStats == null) {
        // İlk giriş - yeni günlük istatistik oluştur
        // Mevcut kullanıcı profilinden hedefi al (bu fonksiyonu implement etmemiz gerekebilir)
        const defaultGoal = 2500.0; // Varsayılan hedef

        todayStats = DailyStats(
          date: dateStr,
          totalWater: type == 'add' ? amount : -amount,
          goalWater: defaultGoal,
          addCount: type == 'add' ? 1 : 0,
          removeCount: type == 'remove' ? 1 : 0,
          achievementPercentage: type == 'add'
              ? (amount / defaultGoal) * 100
              : 0,
          entries: [waterEntry],
          createdAt: now,
        );
      } else {
        // Mevcut istatistikleri güncelle
        final updatedEntries = List<WaterEntry>.from(todayStats.entries);
        updatedEntries.add(waterEntry);

        final newTotalWater = type == 'add'
            ? todayStats.totalWater + amount
            : todayStats.totalWater - amount;

        final newAddCount = type == 'add'
            ? todayStats.addCount + 1
            : todayStats.addCount;

        final newRemoveCount = type == 'remove'
            ? todayStats.removeCount + 1
            : todayStats.removeCount;

        final newAchievementPercentage =
            (newTotalWater / todayStats.goalWater) * 100;

        todayStats = DailyStats(
          date: todayStats.date,
          totalWater: newTotalWater,
          goalWater: todayStats.goalWater,
          addCount: newAddCount,
          removeCount: newRemoveCount,
          achievementPercentage: newAchievementPercentage,
          entries: updatedEntries,
          createdAt: todayStats.createdAt,
        );
      }

      // Güncellenmiş istatistikleri kaydet
      await saveDailyStats(todayStats);

      // Streak günlerini güncelle
      await updateStreakDays();

      DebugLogger.success(
        'Su girişi eklendi: $type $amount ml',
        tag: 'STATISTICS',
      );
    } catch (e) {
      DebugLogger.error('Su girişi ekleme hatası: $e', tag: 'STATISTICS');
      rethrow;
    }
  }

  /// Kullanıcı profil bilgilerinden ideal su tüketimi hesapla
  double calculateIdealWaterIntake(
    double weight,
    int age,
    String gender,
    String activityLevel,
  ) {
    // Temel su ihtiyacı: 35ml/kg
    double baseIntake = weight * 35;

    // Yaş ayarlaması
    if (age > 65) {
      baseIntake *= 0.9; // Yaşlılarda %10 azalma
    } else if (age < 18) {
      baseIntake *= 1.1; // Gençlerde %10 artış
    }

    // Cinsiyet ayarlaması
    if (gender.toLowerCase() == 'male') {
      baseIntake *= 1.1; // Erkeklerde %10 artış
    }

    // Aktivite seviyesi ayarlaması
    switch (activityLevel.toLowerCase()) {
      case 'low':
        break; // Değişiklik yok
      case 'moderate':
        baseIntake *= 1.1; // %10 artış
        break;
      case 'high':
        baseIntake *= 1.2; // %20 artış
        break;
      case 'very_high':
        baseIntake *= 1.3; // %30 artış
        break;
    }

    // Minimum 1500ml, maksimum 4000ml
    return baseIntake.clamp(1500.0, 4000.0);
  }

  /// Kullanıcı profil bilgilerinden performans metrikleri oluştur
  Future<void> updatePerformanceMetricsFromProfile({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
    required double currentGoal,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final idealIntake = calculateIdealWaterIntake(
        weight,
        age,
        gender,
        activityLevel,
      );
      final now = DateTime.now();

      // Mevcut metrikleri al veya yeni oluştur
      PerformanceMetrics? existingMetrics = await getPerformanceMetrics();

      final updatedMetrics = PerformanceMetrics(
        userId: user.uid,
        currentWeight: weight,
        currentHeight: height,
        currentAge: age,
        currentGender: gender,
        currentActivityLevel: activityLevel,
        currentGoal: currentGoal,
        idealIntakeForProfile: idealIntake,
        personalBest: existingMetrics?.personalBest ?? 0.0,
        streakDays: existingMetrics?.streakDays ?? 0,
        totalDaysTracked: existingMetrics?.totalDaysTracked ?? 0,
        profileLastUpdated: now,
        createdAt: existingMetrics?.createdAt ?? now,
      );

      await savePerformanceMetrics(updatedMetrics);

      DebugLogger.success(
        'Performans metrikleri profil güncellemesinden güncellendi',
        tag: 'STATISTICS',
      );
    } catch (e) {
      DebugLogger.error(
        'Performans metrikleri profil güncellemesi hatası: $e',
        tag: 'STATISTICS',
      );
    }
  }

  // Yardımcı metodlar
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }
}
