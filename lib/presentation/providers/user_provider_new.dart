import 'package:flutter/material.dart';
import '../../data/services/hive_service.dart';
import '../../data/models/user_model.dart';
import '../../core/utils/calculations.dart';

/// Kullanıcı verilerini yöneten Provider sınıfı
class UserProvider extends ChangeNotifier {
  final HiveService _hiveService;

  String _firstName = '';
  String _lastName = '';
  int _age = 0;
  double _weight = 0.0;
  double _height = 0.0;
  String _gender = 'male';
  String _activityLevel = 'medium';
  double _dailyWaterGoal = 2000.0;
  bool _isFirstTime = true;

  UserProvider(this._hiveService) {
    _loadUserData();
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

  /// Kullanıcı verilerini Hive'dan yükle
  Future<void> _loadUserData() async {
    try {
      final user = _hiveService.getUser();
      _isFirstTime = _hiveService.isFirstTime();

      if (user != null) {
        _firstName = user.firstName;
        _lastName = user.lastName;
        _age = user.age;
        _weight = user.weight;
        _height = user.height;
        _gender = user.gender;
        _activityLevel = user.activityLevel;
        _dailyWaterGoal = user.dailyWaterGoal;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Kullanıcı verisi yükleme hatası: $e');
    }
  }

  /// Kullanıcı verilerini kaydet
  Future<void> _saveUserData() async {
    try {
      final user = UserModel(
        firstName: _firstName,
        lastName: _lastName,
        age: _age,
        weight: _weight,
        height: _height,
        gender: _gender,
        activityLevel: _activityLevel,
        dailyWaterGoal: _dailyWaterGoal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _hiveService.saveUser(user);
    } catch (e) {
      print('❌ Kullanıcı verisi kaydetme hatası: $e');
      rethrow;
    }
  }

  // Setters
  Future<void> updatePersonalInfo({
    required String firstName,
    required String lastName,
    required int age,
    required double weight,
    required double height,
    required String gender,
    required String activityLevel,
  }) async {
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

    await _saveUserData();
    notifyListeners();
  }

  Future<void> setDailyWaterGoal(double goal) async {
    _dailyWaterGoal = goal;
    await _saveUserData();
    notifyListeners();
  }

  Future<void> completeFirstTime() async {
    _isFirstTime = false;
    await _hiveService.markFirstTimeComplete();
    notifyListeners();
  }

  /// Kullanıcı verilerini temizle
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
    notifyListeners();
  }
}
