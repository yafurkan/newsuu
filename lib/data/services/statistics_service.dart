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

  // Cache sistemi
  final Map<String, DailyStats> _dailyStatsCache = {};
  final Map<String, WeeklyStats> _weeklyStatsCache = {};
  final Map<String, MonthlyStats> _monthlyStatsCache = {};
  PerformanceMetrics? _performanceMetricsCache;
  
  // Cache süresi (5 dakika)
  static const Duration _cacheExpiry = Duration(minutes: 5);
  final Map<String, DateTime> _cacheTimestamps = {};

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

  /// Cache kontrol metodları
  bool _isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  void _setCacheTimestamp(String key) {
    _cacheTimestamps[key] = DateTime.now();
  }

  void _clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) >= _cacheExpiry) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _cacheTimestamps.remove(key);
      _dailyStatsCache.remove(key);
      _weeklyStatsCache.remove(key);
      _monthlyStatsCache.remove(key);
    }
  }

  /// Belirli bir günün istatistiklerini al (Cache'li)
  Future<DailyStats?> getDailyStats(String date) async {
    try {
      // Cache kontrolü
      if (_isCacheValid(date) && _dailyStatsCache.containsKey(date)) {
        DebugLogger.info('Cache\'den günlük istatistik alındı: $date', tag: 'STATISTICS');
        return _dailyStatsCache[date];
      }

      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_stats')
          .doc(date)
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists) {
        final dailyStats = DailyStats.fromJson(doc.data()!);
        
        // Cache'e kaydet
        _dailyStatsCache[date] = dailyStats;
        _setCacheTimestamp(date);
        
        DebugLogger.success('Günlük istatistik Firebase\'den alındı: $date', tag: 'STATISTICS');
        return dailyStats;
      }
      return null;
    } catch (e) {
      DebugLogger.error('Günlük istatistik alma hatası: $e', tag: 'STATISTICS');
      return null;
    }
  }

  /// Haftalık istatistikleri hesapla ve al - Cache invalidation ile
  Future<WeeklyStats?> getWeeklyStats(DateTime weekStart) async {
    try {
      final weekKey = 'week_${_formatDate(weekStart)}';
      final now = DateTime.now();
      final isCurrentWeek = _isSameWeek(weekStart, now);
      
      // Mevcut hafta ise cache'i kullanma - her zaman yeniden hesapla
      if (!isCurrentWeek && _isCacheValid(weekKey) && _weeklyStatsCache.containsKey(weekKey)) {
        DebugLogger.info('Cache\'den haftalık istatistik alındı: $weekKey', tag: 'STATISTICS');
        return _weeklyStatsCache[weekKey];
      }

      final user = _auth.currentUser;
      if (user == null) return null;

      DebugLogger.info('Haftalık istatistik yeniden hesaplanıyor: $weekKey', tag: 'STATISTICS');

      // Batch olarak haftanın tüm günlerini al
      final weekEnd = weekStart.add(const Duration(days: 6));
      final startStr = _formatDate(weekStart);
      final endStr = _formatDate(weekEnd);

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_stats')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startStr)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endStr)
          .orderBy(FieldPath.documentId)
          .get()
          .timeout(const Duration(seconds: 10));

      final dailyStatsList = querySnapshot.docs
          .map((doc) => DailyStats.fromJson(doc.data()))
          .toList();

      DebugLogger.info('Haftalık hesaplama - ${dailyStatsList.length} gün verisi bulundu', tag: 'STATISTICS');

      if (dailyStatsList.isEmpty) return null;

      // Haftalık istatistikleri hesapla
      final totalWater = dailyStatsList.fold<double>(
        0.0,
        (total, stats) => total + stats.totalWater,
      );
      final averageDaily = totalWater / 7;
      final goalAchievementRate = dailyStatsList.isNotEmpty
          ? dailyStatsList.fold<double>(
              0.0,
              (total, stats) => total + stats.achievementPercentage,
            ) / dailyStatsList.length
          : 0.0;

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

      final weeklyStats = WeeklyStats(
        weekStart: startStr,
        weekEnd: endStr,
        totalWater: totalWater,
        averageDaily: averageDaily,
        goalAchievementRate: goalAchievementRate,
        bestDay: bestDay,
        worstDay: worstDay,
        dailyStats: dailyStatsList,
        createdAt: DateTime.now(),
      );

      // Cache'e kaydet (mevcut hafta için kısa süre)
      _weeklyStatsCache[weekKey] = weeklyStats;
      if (isCurrentWeek) {
        // Mevcut hafta için 1 dakika cache
        _cacheTimestamps[weekKey] = DateTime.now().subtract(const Duration(minutes: 4));
      } else {
        _setCacheTimestamp(weekKey);
      }

      DebugLogger.success('Haftalık istatistik hesaplandı: $weekKey - Total: ${totalWater}ml', tag: 'STATISTICS');
      return weeklyStats;
    } catch (e) {
      DebugLogger.error(
        'Haftalık istatistik hesaplama hatası: $e',
        tag: 'STATISTICS',
      );
      return null;
    }
  }

  /// İki tarihin aynı haftada olup olmadığını kontrol et
  bool _isSameWeek(DateTime date1, DateTime date2) {
    final start1 = _getWeekStart(date1);
    final start2 = _getWeekStart(date2);
    return start1.isAtSameMomentAs(start2);
  }

  /// Aylık istatistikleri hesapla ve al - Cache invalidation ile
  Future<MonthlyStats?> getMonthlyStats(DateTime month) async {
    try {
      final monthKey = 'month_${month.year}-${month.month.toString().padLeft(2, '0')}';
      final now = DateTime.now();
      final isCurrentMonth = now.year == month.year && now.month == month.month;
      
      // Mevcut ay ise cache'i kullanma - her zaman yeniden hesapla
      if (!isCurrentMonth && _isCacheValid(monthKey) && _monthlyStatsCache.containsKey(monthKey)) {
        DebugLogger.info('Cache\'den aylık istatistik alındı: $monthKey', tag: 'STATISTICS');
        return _monthlyStatsCache[monthKey];
      }

      final user = _auth.currentUser;
      if (user == null) return null;

      DebugLogger.info('Aylık istatistik yeniden hesaplanıyor: $monthKey', tag: 'STATISTICS');

      // Ayın tüm günlerinin istatistiklerini batch olarak al
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);
      final startStr = _formatDate(firstDay);
      final endStr = _formatDate(lastDay);

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_stats')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startStr)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endStr)
          .orderBy(FieldPath.documentId)
          .get()
          .timeout(const Duration(seconds: 15));

      final dailyStatsList = querySnapshot.docs
          .map((doc) => DailyStats.fromJson(doc.data()))
          .toList();

      DebugLogger.info('Aylık hesaplama - ${dailyStatsList.length} gün verisi bulundu', tag: 'STATISTICS');

      if (dailyStatsList.isEmpty) return null;

      // Haftalık istatistikleri hesapla (cache'den faydalanarak)
      List<WeeklyStats> weeklyStatsList = [];
      DateTime weekStart = _getWeekStart(firstDay);
      
      while (weekStart.isBefore(lastDay) || weekStart.isAtSameMomentAs(lastDay)) {
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
      final goalAchievementRate = dailyStatsList.isNotEmpty
          ? dailyStatsList.fold<double>(
              0.0,
              (total, stats) => total + stats.achievementPercentage,
            ) / dailyStatsList.length
          : 0.0;

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

      final monthlyStats = MonthlyStats(
        month: monthKey.replaceFirst('month_', ''),
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

      // Cache'e kaydet (mevcut ay için kısa süre)
      _monthlyStatsCache[monthKey] = monthlyStats;
      if (isCurrentMonth) {
        // Mevcut ay için 1 dakika cache
        _cacheTimestamps[monthKey] = DateTime.now().subtract(const Duration(minutes: 4));
      } else {
        _setCacheTimestamp(monthKey);
      }

      DebugLogger.success('Aylık istatistik hesaplandı: $monthKey - Total: ${totalWater}ml', tag: 'STATISTICS');
      return monthlyStats;
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

  /// Performans metriklerini al (Cache'li)
  Future<PerformanceMetrics?> getPerformanceMetrics() async {
    try {
      const metricsKey = 'performance_metrics';
      
      // Cache kontrolü
      if (_isCacheValid(metricsKey) && _performanceMetricsCache != null) {
        DebugLogger.info('Cache\'den performans metrikleri alındı', tag: 'STATISTICS');
        return _performanceMetricsCache;
      }

      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('performance_metrics')
          .doc('current')
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists) {
        final metrics = PerformanceMetrics.fromJson(doc.data()!);
        
        // Cache'e kaydet
        _performanceMetricsCache = metrics;
        _setCacheTimestamp(metricsKey);
        
        DebugLogger.success('Performans metrikleri Firebase\'den alındı', tag: 'STATISTICS');
        return metrics;
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

  /// Su girişi ekle ve günlük istatistikleri güncelle - Optimize edilmiş
  Future<void> addWaterEntry({
    required double amount,
    required String type, // 'add' veya 'remove'
    required String source,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        DebugLogger.warning('Kullanıcı oturum açmamış - statistics atlanıyor', tag: 'STATISTICS');
        return;
      }

      final now = DateTime.now();
      final dateStr = _formatDate(now);

      DebugLogger.info('Su girişi ekleniyor: $type $amount ml', tag: 'STATISTICS');

      // Kısa timeout ile bugünkü istatistikleri al
      DailyStats? todayStats;
      try {
        todayStats = await getDailyStats(dateStr).timeout(const Duration(seconds: 3));
      } catch (e) {
        DebugLogger.warning('Günlük istatistik alma timeout: $e', tag: 'STATISTICS');
        todayStats = null;
      }

      // Yeni su girişi oluştur
      final waterEntry = WaterEntry(
        amount: amount,
        timestamp: now,
        type: type,
        source: source,
      );

      if (todayStats == null) {
        // İlk giriş - yeni günlük istatistik oluştur
        const defaultGoal = 2500.0; // Varsayılan hedef

        // İlk giriş silme işlemi olamaz - sadece ekleme kabul et
        final initialTotalWater = type == 'add' ? amount : 0.0;
        final initialAchievement = type == 'add' ? (amount / defaultGoal) * 100 : 0.0;
        
        if (type == 'remove') {
          DebugLogger.warning(
            'İlk giriş silme işlemi olamaz - işlem iptal edildi',
            tag: 'STATISTICS',
          );
          return; // Silme işlemini iptal et
        }

        todayStats = DailyStats(
          date: dateStr,
          totalWater: initialTotalWater,
          goalWater: defaultGoal,
          addCount: type == 'add' ? 1 : 0,
          removeCount: 0, // İlk giriş silme olamaz
          achievementPercentage: initialAchievement,
          entries: [waterEntry],
          createdAt: now,
        );
      } else {
        // Mevcut istatistikleri güncelle
        final updatedEntries = List<WaterEntry>.from(todayStats.entries);
        updatedEntries.add(waterEntry);

        // TotalWater hesaplama - negatif değerlere izin verme
        double newTotalWater;
        if (type == 'add') {
          newTotalWater = todayStats.totalWater + amount;
        } else {
          // Silme işleminde totalWater 0'ın altına düşmemeli
          newTotalWater = (todayStats.totalWater - amount).clamp(0.0, double.infinity);
          
          // Eğer silme işlemi totalWater'ı 0'a düşürürse, gerçek silinen miktarı hesapla
          final actualRemovedAmount = todayStats.totalWater - newTotalWater;
          if (actualRemovedAmount != amount) {
            DebugLogger.warning(
              'Silme işlemi düzeltildi: ${amount}ml yerine ${actualRemovedAmount}ml silindi (negatif önlendi)',
              tag: 'STATISTICS',
            );
          }
        }

        final newAddCount = type == 'add'
            ? todayStats.addCount + 1
            : todayStats.addCount;

        final newRemoveCount = type == 'remove'
            ? todayStats.removeCount + 1
            : todayStats.removeCount;

        // Achievement percentage - negatif olamaz
        final newAchievementPercentage =
            ((newTotalWater / todayStats.goalWater) * 100).clamp(0.0, double.infinity);

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

      // Güncellenmiş istatistikleri kaydet - kısa timeout ile
      try {
        await saveDailyStats(todayStats).timeout(const Duration(seconds: 5));
        
        // Cache'i güncelle
        _dailyStatsCache[dateStr] = todayStats;
        _setCacheTimestamp(dateStr);
        
        DebugLogger.success(
          'Su girişi başarıyla eklendi: $type $amount ml',
          tag: 'STATISTICS',
        );
      } catch (e) {
        DebugLogger.error('İstatistik kaydetme hatası: $e', tag: 'STATISTICS');
        // Hata olsa bile devam et - kritik değil
      }

      // Streak günlerini background'da güncelle - hata olsa bile devam et
      _updateStreakInBackground();

    } catch (e) {
      DebugLogger.error('Su girişi ekleme hatası: $e', tag: 'STATISTICS');
      // Hata fırlat ama kritik değil
    }
  }

  /// Background'da streak güncelle - hata olsa bile ana işlemi etkilemez
  void _updateStreakInBackground() {
    Future.microtask(() async {
      try {
        await updateStreakDays().timeout(const Duration(seconds: 5));
      } catch (e) {
        DebugLogger.warning('Background streak güncelleme hatası: $e', tag: 'STATISTICS');
      }
    });
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

  /// Cache temizleme metodları
  void clearCache() {
    _dailyStatsCache.clear();
    _weeklyStatsCache.clear();
    _monthlyStatsCache.clear();
    _performanceMetricsCache = null;
    _cacheTimestamps.clear();
    
    DebugLogger.info('Tüm cache temizlendi', tag: 'STATISTICS');
  }

  void invalidateCache(String key) {
    _dailyStatsCache.remove(key);
    _weeklyStatsCache.remove(key);
    _monthlyStatsCache.remove(key);
    _cacheTimestamps.remove(key);
    
    if (key == 'performance_metrics') {
      _performanceMetricsCache = null;
    }
    
    DebugLogger.info('Cache invalidated: $key', tag: 'STATISTICS');
  }

  void invalidateDateCache(DateTime date) {
    final dateStr = _formatDate(date);
    final weekKey = 'week_${_formatDate(_getWeekStart(date))}';
    final monthKey = 'month_${date.year}-${date.month.toString().padLeft(2, '0')}';
    
    invalidateCache(dateStr);
    invalidateCache(weekKey);
    invalidateCache(monthKey);
  }

  /// Batch veri yükleme (Performans için)
  Future<Map<String, dynamic>> loadBatchStats({
    required DateTime date,
    bool loadDaily = true,
    bool loadWeekly = true,
    bool loadMonthly = true,
    bool loadPerformance = true,
  }) async {
    _clearExpiredCache();
    
    final results = <String, dynamic>{};
    final futures = <Future>[];

    if (loadDaily) {
      futures.add(
        getDailyStats(_formatDate(date)).then((value) => results['daily'] = value)
      );
    }

    if (loadWeekly) {
      futures.add(
        getWeeklyStats(_getWeekStart(date)).then((value) => results['weekly'] = value)
      );
    }

    if (loadMonthly) {
      futures.add(
        getMonthlyStats(date).then((value) => results['monthly'] = value)
      );
    }

    if (loadPerformance) {
      futures.add(
        getPerformanceMetrics().then((value) => results['performance'] = value)
      );
    }

    await Future.wait(futures);
    
    DebugLogger.success(
      'Batch istatistik yükleme tamamlandı: ${results.keys.join(', ')}',
      tag: 'STATISTICS',
    );
    
    return results;
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
