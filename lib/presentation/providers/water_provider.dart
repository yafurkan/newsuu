import 'package:flutter/material.dart';
import '../../data/services/cloud_sync_service.dart';
import '../../data/models/water_intake_model.dart';
import '../../core/utils/debug_logger.dart';
import 'badge_provider.dart';

/// Su tüketim verilerini yöneten Provider sınıfı (Firebase entegreli)
class WaterProvider extends ChangeNotifier {
  final CloudSyncService _cloudSyncService;

  // State variables
  List<WaterIntakeModel> _todayIntakes = [];
  double _dailyGoal = 2000.0;
  bool _isLoading = false;
  String? _errorMessage;

  // Statistics update callback
  Function(double amount, String type, String source)? _onStatsUpdate;
  
  // Badge provider reference
  BadgeProvider? _badgeProvider;

  WaterProvider(this._cloudSyncService) {
    _loadTodayIntakes();
  }

  // Setters
  void setStatsUpdateCallback(
    Function(double amount, String type, String source)? callback,
  ) {
    _onStatsUpdate = callback;
  }
  
  /// Badge provider'ı ayarla
  void setBadgeProvider(BadgeProvider badgeProvider) {
    _badgeProvider = badgeProvider;
  }

  // Getters
  List<WaterIntakeModel> get todayIntakes => _todayIntakes;
  double get dailyGoal => _dailyGoal;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get todayIntake =>
      _todayIntakes.fold(0.0, (sum, intake) => sum + intake.amount);
  double get progress =>
      dailyGoal > 0 ? (todayIntake / dailyGoal).clamp(0.0, 1.0) : 0.0;
  double get remainingAmount =>
      (dailyGoal - todayIntake).clamp(0.0, double.infinity);
  bool get isGoalCompleted => todayIntake >= dailyGoal;

  /// Bugünün su tüketim verilerini yükle
  Future<void> _loadTodayIntakes() async {
    try {
      _setLoading(true);
      _clearError();

      final today = DateTime.now();
      final intakes = await _cloudSyncService.getDailyWaterIntake(today);

      _todayIntakes = intakes;
      DebugLogger.info(
        '✅ Bugünün su verileri yüklendi: ${_todayIntakes.length} kayıt',
        tag: 'WATER_PROVIDER',
      );

      notifyListeners();
    } catch (e) {
      _setError('Su verileri yüklenirken hata: $e');
      DebugLogger.info(
        '❌ Su verileri yükleme hatası: $e',
        tag: 'WATER_PROVIDER',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Su tüketimi ekle
  Future<void> addWaterIntake(double amount, {String note = ''}) async {
    try {
      _setLoading(true);
      _clearError();

      final now = DateTime.now();
      final intake = WaterIntakeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        timestamp: now,
        note: note,
      );

      // Local state'i güncelle
      _todayIntakes.add(intake);
      notifyListeners();

      // Firebase'e kaydet
      await _cloudSyncService.syncDailyWaterIntake(now, _todayIntakes);

      // Statistics'i güncelle
      _onStatsUpdate?.call(amount, 'add', 'quick_button');

      // Rozet kontrolü yap
      await _checkBadgeAchievements(amount);

      DebugLogger.info(
        '✅ Su tüketimi eklendi: ${amount}ml',
        tag: 'WATER_PROVIDER',
      );
    } catch (e) {
      // Hata durumunda local state'i geri al
      _todayIntakes.removeLast();
      _setError('Su tüketimi eklenirken hata: $e');
      DebugLogger.info(
        '❌ Su tüketimi ekleme hatası: $e',
        tag: 'WATER_PROVIDER',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Su tüketimi sil
  Future<void> removeWaterIntake(String intakeId) async {
    try {
      _setLoading(true);
      _clearError();

      // Silinecek kaydı bul
      final index = _todayIntakes.indexWhere((intake) => intake.id == intakeId);
      if (index == -1) return;

      final removedIntake = _todayIntakes[index];

      // Local state'den sil
      _todayIntakes.removeAt(index);
      notifyListeners();

      // Firebase'i güncelle
      await _cloudSyncService.syncDailyWaterIntake(
        DateTime.now(),
        _todayIntakes,
      );

      // Statistics'i güncelle
      _onStatsUpdate?.call(removedIntake.amount, 'remove', 'manual');

      DebugLogger.info('✅ Su tüketimi silindi', tag: 'WATER_PROVIDER');
    } catch (e) {
      // Hata durumunda local state'i geri al
      final index = _todayIntakes.indexWhere((intake) => intake.id == intakeId);
      if (index != -1) {
        // Silinen kaydı geri ekle (hata durumunda)
        _todayIntakes.insert(
          index,
          WaterIntakeModel(
            id: intakeId,
            amount: 0, // Gerçek değer hatadan dolayı kayboldu
            timestamp: DateTime.now(),
          ),
        );
      }
      _setError('Su tüketimi silinirken hata: $e');
      DebugLogger.info('❌ Su tüketimi silme hatası: $e', tag: 'WATER_PROVIDER');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Günlük hedefi güncelle
  Future<void> updateDailyGoal(double newGoal) async {
    try {
      _dailyGoal = newGoal;
      notifyListeners();

      DebugLogger.info(
        '✅ Günlük hedef güncellendi: ${newGoal}ml',
        tag: 'WATER_PROVIDER',
      );
    } catch (e) {
      _setError('Günlük hedef güncellenirken hata: $e');
      DebugLogger.info(
        '❌ Günlük hedef güncelleme hatası: $e',
        tag: 'WATER_PROVIDER',
      );
    }
  }

  /// UserProvider'dan hedef güncelle
  void updateGoalFromUserProvider(double newGoal) {
    if (_dailyGoal != newGoal) {
      _dailyGoal = newGoal;
      notifyListeners();
    }
  }

  /// Verileri yenile
  Future<void> refreshData() async {
    await _loadTodayIntakes();
  }

  /// Gün geçişini kontrol et
  void checkDayTransitionOnResume() {
    final now = DateTime.now();
    if (_todayIntakes.isNotEmpty) {
      final lastIntakeDate = _todayIntakes.last.timestamp;

      // Farklı gün ise verileri yenile
      if (now.day != lastIntakeDate.day ||
          now.month != lastIntakeDate.month ||
          now.year != lastIntakeDate.year) {
        DebugLogger.info(
          '📅 Gün değişti, veriler yenileniyor...',
          tag: 'WATER_PROVIDER',
        );
        _loadTodayIntakes();
      }
    }
  }

  /// Belirli bir tarihteki verileri al
  Future<List<WaterIntakeModel>?> getWaterIntakeForDate(DateTime date) async {
    try {
      return await _cloudSyncService.getDailyWaterIntake(date);
    } catch (e) {
      DebugLogger.info('❌ Tarih verisi alma hatası: $e', tag: 'WATER_PROVIDER');
      return null;
    }
  }

  /// Tarih aralığındaki verileri al
  Future<Map<String, List<WaterIntakeModel>>?> getWaterIntakeRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      return await _cloudSyncService.getWaterIntakeRange(start, end);
    } catch (e) {
      DebugLogger.info(
        '❌ Tarih aralığı verisi alma hatası: $e',
        tag: 'WATER_PROVIDER',
      );
      return null;
    }
  }

  /// Tüm verileri temizle
  Future<void> clearAllData() async {
    try {
      _setLoading(true);
      _clearError();

      _todayIntakes.clear();
      notifyListeners();

      DebugLogger.info('✅ Tüm su verileri temizlendi', tag: 'WATER_PROVIDER');
    } catch (e) {
      _setError('Veriler temizlenirken hata: $e');
      DebugLogger.info('❌ Veri temizleme hatası: $e', tag: 'WATER_PROVIDER');
    } finally {
      _setLoading(false);
    }
  }

  /// Kullanıcı verilerini temizle (çıkış yapıldığında)
  void clearUserData() {
    _todayIntakes.clear();
    _dailyGoal = 2000.0;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
  
  /// Rozet başarılarını kontrol et
  Future<void> _checkBadgeAchievements(double addedAmount) async {
    if (_badgeProvider == null) return;
    
    try {
      // Buton kullanım istatistiklerini hesapla (basit implementasyon)
      final buttonUsage = <String, int>{
        '250': _todayIntakes.where((i) => i.amount == 250).length,
        '500': _todayIntakes.where((i) => i.amount == 500).length,
        '750': _todayIntakes.where((i) => i.amount == 750).length,
        '1000': _todayIntakes.where((i) => i.amount == 1000).length,
      };
      
      // Ardışık gün sayısını hesapla (basit implementasyon - gerçekte daha karmaşık olmalı)
      final consecutiveDays = await _calculateConsecutiveDays();
      
      final newBadges = await _badgeProvider!.checkWaterAdditionBadges(
        amount: addedAmount.toInt(),
        dailyTotal: todayIntake.toInt(),
        dailyGoal: dailyGoal.toInt(),
        consecutiveDays: consecutiveDays,
        buttonUsage: buttonUsage,
      );
      
      // Yeni rozetler varsa bildirim göster
      if (newBadges.isNotEmpty) {
        DebugLogger.success(
          'Yeni rozetler kazanıldı: ${newBadges.map((b) => b.name).join(', ')}',
          tag: 'WATER_PROVIDER',
        );
      }
    } catch (e) {
      DebugLogger.error('Rozet kontrolü hatası: $e', tag: 'WATER_PROVIDER');
    }
  }
  
  /// Ardışık gün sayısını hesapla (basit implementasyon)
  Future<int> _calculateConsecutiveDays() async {
    try {
      // Son 30 günü kontrol et
      final now = DateTime.now();
      int consecutiveDays = 0;
      
      for (int i = 0; i < 30; i++) {
        final checkDate = now.subtract(Duration(days: i));
        final dayIntakes = await getWaterIntakeForDate(checkDate);
        
        if (dayIntakes != null && dayIntakes.isNotEmpty) {
          consecutiveDays++;
        } else {
          break;
        }
      }
      
      return consecutiveDays;
    } catch (e) {
      DebugLogger.error('Ardışık gün hesaplama hatası: $e', tag: 'WATER_PROVIDER');
      return 1; // En az bugün var
    }
  }
}
