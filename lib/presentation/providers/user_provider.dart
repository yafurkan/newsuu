import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/cloud_sync_service.dart';
import '../../core/utils/calculations.dart';
import '../../core/utils/debug_logger.dart';

/// Kullanıcı verilerini yöneten Provider sınıfı (Firebase entegreli)
class UserProvider extends ChangeNotifier {
  final CloudSyncService _cloudSyncService;
  VoidCallback? _onGoalUpdated; // WaterProvider'ı bilgilendirmek için

  String _firstName = '';
  String _lastName = '';
  int _age = 0;
  double _weight = 0.0;
  double _height = 0.0;
  String _gender = 'male';
  String _activityLevel = 'medium';
  double _dailyWaterGoal = 2000.0;
  bool _isFirstTime = true;
  bool _isLoading = false;
  String? _errorMessage;

  UserProvider(this._cloudSyncService) {
    loadUserData();
  }

  // Callback setter (WaterProvider tarafından set edilecek)
  void setGoalUpdateCallback(VoidCallback callback) {
    _onGoalUpdated = callback;
  }

  // Getters
  String get firstName => _firstName;
  String get lastName => _lastName;
  int get age => _age;
  double get weight => _weight;
  double get height => _height;
  String get gender => _gender;
  String get activityLevel => _activityLevel;
  double get dailyWaterGoal => _dailyWaterGoal;
  bool get isFirstTime => _isFirstTime;
  String get fullName => '$_firstName $_lastName';
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Kullanıcı verilerini Firebase'dan yükle
  Future<void> loadUserData() async {
    try {
      _setLoading(true);
      _clearError();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userData = await _cloudSyncService.getUserData(user.uid);

      if (userData != null) {
        _firstName = userData['firstName'] ?? '';
        _lastName = userData['lastName'] ?? '';
        _age = userData['age'] ?? 0;
        _weight = (userData['weight'] ?? 0.0).toDouble();
        _height = (userData['height'] ?? 0.0).toDouble();
        _gender = userData['gender'] ?? 'male';
        _activityLevel = userData['activityLevel'] ?? 'medium';
        _dailyWaterGoal = (userData['dailyWaterGoal'] ?? 2000.0).toDouble();
        _isFirstTime = userData['isFirstTime'] ?? true;
        notifyListeners();
      }
    } catch (e) {
      _setError('Kullanıcı verisi yükleme hatası: $e');
      DebugLogger.info(
        '❌ Kullanıcı verisi yükleme hatası: $e',
        tag: 'USER_PROVIDER',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Kullanıcı verilerini Firebase'e kaydet
  Future<void> _saveUserData() async {
    try {
      _setLoading(true);
      _clearError();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı oturum açmamış');
      }

      final userData = {
        'firstName': _firstName,
        'lastName': _lastName,
        'age': _age,
        'weight': _weight,
        'height': _height,
        'gender': _gender,
        'activityLevel': _activityLevel,
        'dailyWaterGoal': _dailyWaterGoal,
        'isFirstTime': _isFirstTime,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _cloudSyncService.saveUserData(user.uid, userData);
    } catch (e) {
      _setError('Kullanıcı verisi kaydetme hatası: $e');
      DebugLogger.info(
        '❌ Kullanıcı verisi kaydetme hatası: $e',
        tag: 'USER_PROVIDER',
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Kişisel bilgileri güncelle
  Future<void> updatePersonalInfo({
    required String firstName,
    required String lastName,
    required int age,
    required double weight,
    required double height,
    required String gender,
    required String activityLevel,
  }) async {
    try {
      DebugLogger.info(
        '🔄 Kişisel bilgiler güncelleniyor...',
        tag: 'USER_PROVIDER',
      );

      _firstName = firstName;
      _lastName = lastName;
      _age = age;
      _weight = weight;
      _height = height;
      _gender = gender;
      _activityLevel = activityLevel;

      // Su hedefini otomatik hesapla
      _dailyWaterGoal = WaterCalculations.calculateDailyWaterNeed(
        weight: weight,
        age: age,
        gender: gender,
        activityLevel: activityLevel,
      );

      DebugLogger.info(
        '📊 Su hedefi hesaplandı: ${_dailyWaterGoal}ml',
        tag: 'USER_PROVIDER',
      );

      // Önce local'e kaydet ki hata olursa bile kullanıcı ilerleyebilsin
      notifyListeners();

      // WaterProvider'ı hedef değişikliği hakkında bilgilendir
      _onGoalUpdated?.call();

      // Sonra Firebase'e kaydetmeye çalış (background'da)
      try {
        await _saveUserData();
        DebugLogger.info(
          '✅ Kişisel bilgiler Firebase\'e kaydedildi',
          tag: 'USER_PROVIDER',
        );
      } catch (e) {
        // Firebase hatası olursa log'la ama fonksiyonu başarısız sayma
        DebugLogger.info(
          '⚠️ Firebase kayıt hatası (offline devam): $e',
          tag: 'USER_PROVIDER',
        );
      }
    } catch (e) {
      _setError('Kişisel bilgi güncelleme hatası: $e');
      DebugLogger.info(
        '❌ Kişisel bilgi güncelleme hatası: $e',
        tag: 'USER_PROVIDER',
      );
      rethrow;
    }
  }

  /// Günlük su hedefini güncelle
  Future<void> setDailyWaterGoal(double goal) async {
    _dailyWaterGoal = goal;
    await _saveUserData();

    // WaterProvider'ı hedef değişikliği hakkında bilgilendir
    _onGoalUpdated?.call();

    notifyListeners();
  }

  /// İlk kez setup'ı tamamla
  Future<void> completeFirstTime() async {
    try {
      _isFirstTime = false;

      // Önce local'e kaydet ki hata olursa bile kullanıcı ilerleyebilsin
      notifyListeners();

      // Sonra Firebase'e kaydetmeye çalış (background'da)
      try {
        await _saveUserData();
        DebugLogger.info(
          '✅ Kullanıcı verisi Firebase\'e kaydedildi',
          tag: 'USER_PROVIDER',
        );
      } catch (e) {
        // Firebase hatası olursa log'la ama fonksiyonu başarısız sayma
        DebugLogger.info(
          '⚠️ Firebase kayıt hatası (offline devam): $e',
          tag: 'USER_PROVIDER',
        );
      }
    } catch (e) {
      _setError('İlk kez tamamlama hatası: $e');
      DebugLogger.info('❌ İlk kez tamamlama hatası: $e', tag: 'USER_PROVIDER');
      rethrow;
    }
  }

  /// Kullanıcı verilerini temizle (çıkış yapıldığında)
  Future<void> clearUserData() async {
    _firstName = '';
    _lastName = '';
    _age = 0;
    _weight = 0.0;
    _height = 0.0;
    _gender = 'male';
    _activityLevel = 'medium';
    _dailyWaterGoal = 2000.0;
    _isFirstTime = true;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Auth durumu değiştiğinde çağır
  Future<void> onAuthStateChanged(User? user) async {
    if (user != null) {
      await loadUserData();
    } else {
      await clearUserData();
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
