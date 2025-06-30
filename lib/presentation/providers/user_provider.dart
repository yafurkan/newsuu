import 'package:flutter/material.dart';

/// Kullanıcı verilerini yöneten Provider sınıfı
class UserProvider extends ChangeNotifier {
  String _firstName = '';
  String _lastName = '';
  int _age = 0;
  double _weight = 0.0;
  double _height = 0.0;
  String _gender = 'male';
  String _activityLevel = 'medium';
  double _dailyWaterGoal = 2000.0;
  bool _isFirstTime = true;

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

  // Setters
  void updatePersonalInfo({
    required String firstName,
    required String lastName,
    required int age,
    required double weight,
    required double height,
    required String gender,
    required String activityLevel,
  }) {
    _firstName = firstName;
    _lastName = lastName;
    _age = age;
    _weight = weight;
    _height = height;
    _gender = gender;
    _activityLevel = activityLevel;
    notifyListeners();
  }

  void setDailyWaterGoal(double goal) {
    _dailyWaterGoal = goal;
    notifyListeners();
  }

  void completeOnboarding() {
    _isFirstTime = false;
    notifyListeners();
  }
}
