import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/services/hive_service.dart';
import '../../data/models/water_intake_model.dart';

/// Su alımı verilerini yöneten Provider sınıfı
class WaterProvider extends ChangeNotifier {
  final HiveService _hiveService;

  double _todayIntake = 0.0;
  double _dailyGoal = 2000.0;
  List<WaterIntakeModel> _todayIntakes = [];
  DateTime _lastCheckDate = DateTime.now();
  Timer? _dailyResetTimer;

  WaterProvider(this._hiveService) {
    _loadTodayData();
    _setupDailyReset();
  }

  // Getters
  double get todayIntake => _todayIntake;
  double get dailyGoal => _dailyGoal;
  List<WaterIntakeModel> get todayIntakes => List.unmodifiable(_todayIntakes);
  double get progress => _dailyGoal > 0 ? (_todayIntake / _dailyGoal) * 100 : 0;
  bool get isGoalCompleted => _todayIntake >= _dailyGoal;
  double get remainingAmount => _dailyGoal - _todayIntake;

  /// Bugünkü verileri Hive'dan yükle
  Future<void> _loadTodayData() async {
    try {
      // Günlük geçiş kontrolü yap
      await _checkDayTransition();

      _todayIntakes = _hiveService.getTodayWaterIntakes();
      _calculateTodayIntake();
      notifyListeners();
    } catch (e) {
      print('❌ Bugünkü veriler yükleme hatası: $e');
    }
  }

  /// Günlük geçiş kontrolü (uygulama açıldığında)
  Future<void> _checkDayTransition() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCheck = DateTime(
      _lastCheckDate.year,
      _lastCheckDate.month,
      _lastCheckDate.day,
    );

    if (today.isAfter(lastCheck)) {
      print('🔄 Yeni güne geçiş tespit edildi: ${today.toString()}');
      _lastCheckDate = now;
      await _performDayReset();
    }
  }

  /// Günlük sıfırlama sistemini kur
  void _setupDailyReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    print(
      '⏰ Günlük sıfırlama ${timeUntilMidnight.inMinutes} dakika sonra başlayacak',
    );

    // İlk gece yarısı için timer
    _dailyResetTimer = Timer(timeUntilMidnight, () {
      _performDayReset();
      _setupRecurringDailyReset();
    });
  }

  /// Tekrarlayan günlük sıfırlama timer'ını kur
  void _setupRecurringDailyReset() {
    // Her 24 saatte bir çalışacak timer
    _dailyResetTimer = Timer.periodic(const Duration(days: 1), (timer) {
      _performDayReset();
    });
  }

  /// Günlük sıfırlama işlemini gerçekleştir
  Future<void> _performDayReset() async {
    try {
      print('🌅 Günlük sıfırlama başlatılıyor...');

      final oldIntake = _todayIntake;

      // Verileri sıfırla
      _todayIntake = 0.0;
      _todayIntakes.clear();
      _lastCheckDate = DateTime.now();

      // Yeni günün verilerini yükle
      await _loadTodayData();

      print('✅ Günlük sıfırlama tamamlandı:');
      print('   - Önceki alım: ${oldIntake.toInt()}ml');
      print('   - Yeni hedef: ${_dailyGoal.toInt()}ml');

      notifyListeners();
    } catch (e) {
      print('❌ Günlük sıfırlama hatası: $e');
    }
  }

  /// Bugünkü toplam su alımını hesapla
  void _calculateTodayIntake() {
    _todayIntake = _todayIntakes.fold(
      0.0,
      (sum, intake) => sum + intake.amount,
    );
  }

  /// Su ekleme
  Future<void> addWater(double amount, {String? note}) async {
    try {
      final intake = WaterIntakeModel(
        amount: amount,
        timestamp: DateTime.now(),
        note: note,
      );

      // Hive'a kaydet
      await _hiveService.saveWaterIntake(intake);

      // Local listeye ekle
      _todayIntakes.insert(0, intake); // En yeniler önce
      _todayIntake += amount;

      notifyListeners();
    } catch (e) {
      print('❌ Su ekleme hatası: $e');
      rethrow;
    }
  }

  /// Su alımını sil
  Future<void> removeWaterIntake(int index) async {
    try {
      if (index >= 0 && index < _todayIntakes.length) {
        final intake = _todayIntakes[index];

        // Hive'dan sil
        await _hiveService.deleteWaterIntake(intake);

        // Local listeden sil
        _todayIntake -= intake.amount;
        _todayIntakes.removeAt(index);

        notifyListeners();
      }
    } catch (e) {
      print('❌ Su alımı silme hatası: $e');
      rethrow;
    }
  }

  /// Günlük hedef güncelleme
  void updateDailyGoal(double goal) {
    _dailyGoal = goal;
    notifyListeners();
  }

  /// Güne sıfırlama (yeni güne geçişte) - Manuel sıfırlama
  Future<void> resetDay() async {
    await _performDayReset();
  }

  /// Provider'ı dispose et
  @override
  void dispose() {
    _dailyResetTimer?.cancel();
    super.dispose();
  }

  /// Uygulama resume olduğunda kontrol et
  void checkDayTransitionOnResume() {
    _checkDayTransition();
  }

  /// Belirli tarih aralığındaki verileri getir (istatistikler için)
  List<WaterIntakeModel> getWaterIntakesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _hiveService.getWaterIntakesByDateRange(startDate, endDate);
  }

  /// Haftalık istatistik
  Map<DateTime, double> getWeeklyStats() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final weeklyIntakes = getWaterIntakesByDateRange(weekStart, weekEnd);
    final Map<DateTime, double> dailyTotals = {};

    // Her gün için toplam hesapla
    for (int i = 0; i < 7; i++) {
      final date = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      dailyTotals[date] = 0.0;
    }

    for (final intake in weeklyIntakes) {
      final date = DateTime(
        intake.timestamp.year,
        intake.timestamp.month,
        intake.timestamp.day,
      );
      dailyTotals[date] = (dailyTotals[date] ?? 0.0) + intake.amount;
    }

    return dailyTotals;
  }

  /// Aylık istatistik
  Map<DateTime, double> getMonthlyStats() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final monthlyIntakes = getWaterIntakesByDateRange(monthStart, nextMonth);
    final Map<DateTime, double> dailyTotals = {};

    // Ayın her günü için toplam hesapla
    final daysInMonth = nextMonth.subtract(const Duration(days: 1)).day;
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(now.year, now.month, i);
      dailyTotals[date] = 0.0;
    }

    for (final intake in monthlyIntakes) {
      final date = DateTime(
        intake.timestamp.year,
        intake.timestamp.month,
        intake.timestamp.day,
      );
      dailyTotals[date] = (dailyTotals[date] ?? 0.0) + intake.amount;
    }

    return dailyTotals;
  }

  /// Verileri yenile
  Future<void> refreshData() async {
    await _loadTodayData();
  }

  /// Son N gün için su alımlarını getir
  List<WaterIntakeModel> getIntakesForLastDays(int days) {
    final startDate = DateTime.now().subtract(Duration(days: days));
    final endDate = DateTime.now().add(const Duration(days: 1));
    return getWaterIntakesByDateRange(startDate, endDate);
  }

  /// Belirli bir tarih için su alımlarını getir
  List<WaterIntakeModel> getIntakesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _hiveService.getWaterIntakesByDateRange(startOfDay, endOfDay);
  }
}
