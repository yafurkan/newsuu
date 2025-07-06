import 'package:flutter/material.dart';
import '../../data/services/cloud_sync_service.dart';
import '../../data/models/water_intake_model.dart';

/// Su tüketim verilerini yöneten Provider sınıfı (Firebase entegreli)
class WaterProvider extends ChangeNotifier {
  final CloudSyncService _cloudSyncService;

  // State variables
  List<WaterIntakeModel> _todayIntakes = [];
  double _dailyGoal = 2000.0;
  bool _isLoading = false;
  String? _errorMessage;

  WaterProvider(this._cloudSyncService) {
    _loadTodayIntakes();
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
      print('✅ Bugünün su verileri yüklendi: ${_todayIntakes.length} kayıt');

      notifyListeners();
    } catch (e) {
      _setError('Su verileri yüklenirken hata: $e');
      print('❌ Su verileri yükleme hatası: $e');
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

      print('✅ Su tüketimi eklendi: ${amount}ml');
    } catch (e) {
      // Hata durumunda local state'i geri al
      _todayIntakes.removeLast();
      _setError('Su tüketimi eklenirken hata: $e');
      print('❌ Su tüketimi ekleme hatası: $e');
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

      // Local state'den sil
      _todayIntakes.removeAt(index);
      notifyListeners();

      // Firebase'i güncelle
      await _cloudSyncService.syncDailyWaterIntake(
        DateTime.now(),
        _todayIntakes,
      );

      print('✅ Su tüketimi silindi');
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
      print('❌ Su tüketimi silme hatası: $e');
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

      print('✅ Günlük hedef güncellendi: ${newGoal}ml');
    } catch (e) {
      _setError('Günlük hedef güncellenirken hata: $e');
      print('❌ Günlük hedef güncelleme hatası: $e');
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
        print('📅 Gün değişti, veriler yenileniyor...');
        _loadTodayIntakes();
      }
    }
  }

  /// Belirli bir tarihteki verileri al
  Future<List<WaterIntakeModel>?> getWaterIntakeForDate(DateTime date) async {
    try {
      return await _cloudSyncService.getDailyWaterIntake(date);
    } catch (e) {
      print('❌ Tarih verisi alma hatası: $e');
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
      print('❌ Tarih aralığı verisi alma hatası: $e');
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

      print('✅ Tüm su verileri temizlendi');
    } catch (e) {
      _setError('Veriler temizlenirken hata: $e');
      print('❌ Veri temizleme hatası: $e');
    } finally {
      _setLoading(false);
    }
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
}
