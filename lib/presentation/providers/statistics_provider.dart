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

  /// Initialize statistics data
  Future<void> initializeStats() async {
    await Future.wait([
      loadDailyStats(_selectedDate),
      loadWeeklyStats(_selectedDate),
      loadMonthlyStats(_selectedDate),
      loadPerformanceMetrics(),
    ]);
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

  /// Update statistics when water is added/removed
  Future<void> updateStatsOnWaterChange({
    required double amount,
    required String type, // 'add' or 'remove'
    required String source,
  }) async {
    try {
      await _statisticsService.addWaterEntry(
        amount: amount,
        type: type,
        source: source,
      );

      // Reload current day stats
      await loadDailyStats(_selectedDate);

      // If viewing current week/month, reload those too
      final now = DateTime.now();
      if (_isSameWeek(_selectedDate, now)) {
        await loadWeeklyStats(_selectedDate);
      }
      if (_isSameMonth(_selectedDate, now)) {
        await loadMonthlyStats(_selectedDate);
      }

      DebugLogger.success(
        'İstatistikler güncellendi: $type $amount ml',
        tag: 'STATS_PROVIDER',
      );
    } catch (e) {
      DebugLogger.error(
        'İstatistik güncelleme hatası: $e',
        tag: 'STATS_PROVIDER',
      );
    }
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

  /// Refresh all current stats
  Future<void> refreshAll() async {
    await initializeStats();
  }

  /// Clear all user data when signing out
  void clearUserData() {
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
      'StatisticsProvider kullanıcı verileri temizlendi',
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
