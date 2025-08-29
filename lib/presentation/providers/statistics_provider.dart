import 'package:flutter/foundation.dart';

import '../../data/models/statistics_models.dart';
import '../../data/services/statistics_service.dart';
import '../../core/utils/debug_logger.dart';

class StatisticsProvider with ChangeNotifier {
  final StatisticsService _statisticsService = StatisticsService();

  // Current stats
  DailyStats? _currentDailyStats;
  WeeklyStats? _currentWeeklyStats;
  MonthlyStats? _currentMonthlyStats;
  PerformanceMetrics? _currentPerformanceMetrics;

  // Loading states
  bool _isLoadingDaily = false;
  bool _isLoadingWeekly = false;
  bool _isLoadingMonthly = false;
  bool _isLoadingPerformance = false;

  // Selected period for viewing
  DateTime _selectedDate = DateTime.now();
  StatsPeriod _selectedPeriod = StatsPeriod.daily;

  // Getters
  DailyStats? get currentDailyStats => _currentDailyStats;
  WeeklyStats? get currentWeeklyStats => _currentWeeklyStats;
  MonthlyStats? get currentMonthlyStats => _currentMonthlyStats;
  PerformanceMetrics? get currentPerformanceMetrics =>
      _currentPerformanceMetrics;

  bool get isLoadingDaily => _isLoadingDaily;
  bool get isLoadingWeekly => _isLoadingWeekly;
  bool get isLoadingMonthly => _isLoadingMonthly;
  bool get isLoadingPerformance => _isLoadingPerformance;

  DateTime get selectedDate => _selectedDate;
  StatsPeriod get selectedPeriod => _selectedPeriod;

  bool get isLoading =>
      _isLoadingDaily ||
      _isLoadingWeekly ||
      _isLoadingMonthly ||
      _isLoadingPerformance;

  /// Initialize statistics data (Optimize edilmiş)
  Future<void> initializeStats() async {
    try {
      // Batch loading kullanarak tüm istatistikleri paralel yükle
      final results = await _statisticsService.loadBatchStats(
        date: _selectedDate,
        loadDaily: true,
        loadWeekly: true,
        loadMonthly: true,
        loadPerformance: true,
      );

      // Sonuçları provider state'ine aktar
      _currentDailyStats = results['daily'] as DailyStats?;
      _currentWeeklyStats = results['weekly'] as WeeklyStats?;
      _currentMonthlyStats = results['monthly'] as MonthlyStats?;
      _currentPerformanceMetrics = results['performance'] as PerformanceMetrics?;

      notifyListeners();

      DebugLogger.success(
        'Tüm istatistikler batch olarak yüklendi',
        tag: 'STATS_PROVIDER',
      );
    } catch (e) {
      DebugLogger.error(
        'Batch istatistik yükleme hatası: $e',
        tag: 'STATS_PROVIDER',
      );
      
      // Fallback: Eski yöntemle yükle
      await Future.wait([
        loadDailyStats(_selectedDate),
        loadWeeklyStats(_selectedDate),
        loadMonthlyStats(_selectedDate),
        loadPerformanceMetrics(),
      ]);
    }
  }

  /// Load daily statistics
  Future<void> loadDailyStats(DateTime date) async {
    _isLoadingDaily = true;
    notifyListeners();

    try {
      final dateStr = _formatDate(date);
      _currentDailyStats = await _statisticsService.getDailyStats(dateStr);

      DebugLogger.info(
        'Günlük istatistikler yüklendi: $dateStr',
        tag: 'STATS_PROVIDER',
      );
    } catch (e) {
      DebugLogger.error(
        'Günlük istatistik yükleme hatası: $e',
        tag: 'STATS_PROVIDER',
      );
    } finally {
      _isLoadingDaily = false;
      notifyListeners();
    }
  }

  /// Load weekly statistics
  Future<void> loadWeeklyStats(DateTime date) async {
    _isLoadingWeekly = true;
    notifyListeners();

    try {
      final weekStart = _getWeekStart(date);
      _currentWeeklyStats = await _statisticsService.getWeeklyStats(weekStart);

      DebugLogger.info(
        'Haftalık istatistikler yüklendi: ${_formatDate(weekStart)}',
        tag: 'STATS_PROVIDER',
      );
    } catch (e) {
      DebugLogger.error(
        'Haftalık istatistik yükleme hatası: $e',
        tag: 'STATS_PROVIDER',
      );
    } finally {
      _isLoadingWeekly = false;
      notifyListeners();
    }
  }

  /// Load monthly statistics
  Future<void> loadMonthlyStats(DateTime date) async {
    _isLoadingMonthly = true;
    notifyListeners();

    try {
      _currentMonthlyStats = await _statisticsService.getMonthlyStats(date);

      DebugLogger.info(
        'Aylık istatistikler yüklendi: ${date.year}-${date.month}',
        tag: 'STATS_PROVIDER',
      );
    } catch (e) {
      DebugLogger.error(
        'Aylık istatistik yükleme hatası: $e',
        tag: 'STATS_PROVIDER',
      );
    } finally {
      _isLoadingMonthly = false;
      notifyListeners();
    }
  }

  /// Load performance metrics
  Future<void> loadPerformanceMetrics() async {
    _isLoadingPerformance = true;
    notifyListeners();

    try {
      _currentPerformanceMetrics = await _statisticsService
          .getPerformanceMetrics();

      DebugLogger.info('Performans metrikleri yüklendi', tag: 'STATS_PROVIDER');
    } catch (e) {
      DebugLogger.error(
        'Performans metrik yükleme hatası: $e',
        tag: 'STATS_PROVIDER',
      );
    } finally {
      _isLoadingPerformance = false;
      notifyListeners();
    }
  }

  /// Change selected period
  void changePeriod(StatsPeriod period) {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      notifyListeners();
    }
  }

  /// Change selected date and reload data
  Future<void> changeDate(DateTime date) async {
    if (_selectedDate != date) {
      _selectedDate = date;
      notifyListeners();

      // Reload relevant stats based on period
      switch (_selectedPeriod) {
        case StatsPeriod.daily:
          await loadDailyStats(date);
          break;
        case StatsPeriod.weekly:
          await loadWeeklyStats(date);
          break;
        case StatsPeriod.monthly:
          await loadMonthlyStats(date);
          break;
      }
    }
  }

  /// Navigate to previous period
  Future<void> navigateToPrevious() async {
    DateTime newDate;
    switch (_selectedPeriod) {
      case StatsPeriod.daily:
        newDate = _selectedDate.subtract(const Duration(days: 1));
        break;
      case StatsPeriod.weekly:
        newDate = _selectedDate.subtract(const Duration(days: 7));
        break;
      case StatsPeriod.monthly:
        newDate = DateTime(
          _selectedDate.year,
          _selectedDate.month - 1,
          _selectedDate.day,
        );
        break;
    }
    await changeDate(newDate);
  }

  /// Navigate to next period
  Future<void> navigateToNext() async {
    DateTime newDate;
    switch (_selectedPeriod) {
      case StatsPeriod.daily:
        newDate = _selectedDate.add(const Duration(days: 1));
        break;
      case StatsPeriod.weekly:
        newDate = _selectedDate.add(const Duration(days: 7));
        break;
      case StatsPeriod.monthly:
        newDate = DateTime(
          _selectedDate.year,
          _selectedDate.month + 1,
          _selectedDate.day,
        );
        break;
    }
    await changeDate(newDate);
  }

  /// Update statistics when water is added/removed - Optimize edilmiş
  Future<void> updateStatsOnWaterChange({
    required double amount,
    required String type, // 'add' or 'remove'
    required String source,
  }) async {
    try {
      DebugLogger.info(
        'İstatistik güncelleme başlatılıyor: $type $amount ml',
        tag: 'STATS_PROVIDER',
      );

      // Statistics service'e kısa timeout ile gönder
      await _statisticsService.addWaterEntry(
        amount: amount,
        type: type,
        source: source,
      ).timeout(const Duration(seconds: 5));

      // Sadece bugünkü istatistikleri yenile - kısa timeout ile
      try {
        await loadDailyStats(_selectedDate).timeout(const Duration(seconds: 3));
        
        DebugLogger.success(
          'Günlük istatistikler güncellendi: $type $amount ml',
          tag: 'STATS_PROVIDER',
        );
      } catch (e) {
        DebugLogger.warning(
          'Günlük istatistik yenileme timeout: $e',
          tag: 'STATS_PROVIDER',
        );
      }

      // Haftalık ve aylık istatistikleri background'da yenile
      _refreshWeeklyMonthlyInBackground();

    } catch (e) {
      DebugLogger.error(
        'İstatistik güncelleme hatası: $e',
        tag: 'STATS_PROVIDER',
      );
      // Hata olsa bile devam et - kritik değil
    }
  }

  /// Background'da haftalık ve aylık istatistikleri yenile - Cache invalidation ile
  void _refreshWeeklyMonthlyInBackground() {
    Future.microtask(() async {
      try {
        final now = DateTime.now();
        
        // Mevcut hafta/ay için cache'i invalidate et
        if (_isSameWeek(_selectedDate, now)) {
          _statisticsService.invalidateDateCache(_selectedDate);
          await loadWeeklyStats(_selectedDate).timeout(const Duration(seconds: 8));
          DebugLogger.info('Haftalık istatistikler background\'da yenilendi', tag: 'STATS_PROVIDER');
        }
        if (_isSameMonth(_selectedDate, now)) {
          _statisticsService.invalidateDateCache(_selectedDate);
          await loadMonthlyStats(_selectedDate).timeout(const Duration(seconds: 8));
          DebugLogger.info('Aylık istatistikler background\'da yenilendi', tag: 'STATS_PROVIDER');
        }
        
        DebugLogger.success('Background istatistik yenileme tamamlandı', tag: 'STATS_PROVIDER');
      } catch (e) {
        DebugLogger.warning('Background istatistik yenileme hatası: $e', tag: 'STATS_PROVIDER');
      }
    });
  }

  /// Update performance metrics when user profile changes
  Future<void> updatePerformanceFromProfile({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
    required double currentGoal,
  }) async {
    try {
      await _statisticsService.updatePerformanceMetricsFromProfile(
        weight: weight,
        height: height,
        age: age,
        gender: gender,
        activityLevel: activityLevel,
        currentGoal: currentGoal,
      );

      // Reload performance metrics
      await loadPerformanceMetrics();

      DebugLogger.success(
        'Performans metrikleri profil değişikliğinden güncellendi',
        tag: 'STATS_PROVIDER',
      );
    } catch (e) {
      DebugLogger.error(
        'Performans metrikleri profil güncellemesi hatası: $e',
        tag: 'STATS_PROVIDER',
      );
    }
  }

  /// Refresh all current stats (Cache'i temizleyerek) - Timeout'lu
  Future<void> refreshAll() async {
    try {
      DebugLogger.info('Tüm istatistikler yenileniyor...', tag: 'STATS_PROVIDER');
      
      // Cache'i temizle
      _statisticsService.clearCache();
      
      // Tüm loading state'lerini true yap
      _isLoadingDaily = true;
      _isLoadingWeekly = true;
      _isLoadingMonthly = true;
      _isLoadingPerformance = true;
      notifyListeners();
      
      // Kısa timeout ile yeniden yükle
      await initializeStats().timeout(const Duration(seconds: 10));
      
      DebugLogger.success('Tüm istatistikler yenilendi', tag: 'STATS_PROVIDER');
    } catch (e) {
      DebugLogger.error('İstatistik yenileme hatası: $e', tag: 'STATS_PROVIDER');
      
      // Loading state'lerini temizle
      _isLoadingDaily = false;
      _isLoadingWeekly = false;
      _isLoadingMonthly = false;
      _isLoadingPerformance = false;
      notifyListeners();
    }
  }

  /// Cache'i invalidate et ve belirli tarihi yenile
  Future<void> invalidateAndRefresh(DateTime date) async {
    _statisticsService.invalidateDateCache(date);
    
    if (_selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day) {
      await initializeStats();
    }
  }

  /// Clear all user data when signing out
  void clearUserData() {
    // Cache'i temizle
    _statisticsService.clearCache();
    
    _currentDailyStats = null;
    _currentWeeklyStats = null;
    _currentMonthlyStats = null;
    _currentPerformanceMetrics = null;

    _isLoadingDaily = false;
    _isLoadingWeekly = false;
    _isLoadingMonthly = false;
    _isLoadingPerformance = false;

    _selectedDate = DateTime.now();
    _selectedPeriod = StatsPeriod.daily;

    notifyListeners();

    DebugLogger.info(
      'StatisticsProvider kullanıcı verileri ve cache temizlendi',
      tag: 'STATS_PROVIDER',
    );
  }

  /// Helper methods
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  bool _isSameWeek(DateTime date1, DateTime date2) {
    final start1 = _getWeekStart(date1);
    final start2 = _getWeekStart(date2);
    return start1.isAtSameMomentAs(start2);
  }

  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }
}

enum StatsPeriod { daily, weekly, monthly }
