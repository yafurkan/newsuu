import 'package:flutter/material.dart';

/// Su alımı verilerini yöneten Provider sınıfı
class WaterProvider extends ChangeNotifier {
  double _todayIntake = 0.0;
  double _dailyGoal = 2000.0;
  List<WaterIntake> _todayIntakes = [];

  // Getters
  double get todayIntake => _todayIntake;
  double get dailyGoal => _dailyGoal;
  List<WaterIntake> get todayIntakes => _todayIntakes;
  double get progress => _dailyGoal > 0 ? (_todayIntake / _dailyGoal) * 100 : 0;
  bool get isGoalCompleted => _todayIntake >= _dailyGoal;
  double get remainingAmount => _dailyGoal - _todayIntake;

  // Su ekleme
  void addWater(double amount) {
    _todayIntake += amount;
    _todayIntakes.add(WaterIntake(amount: amount, timestamp: DateTime.now()));
    notifyListeners();
  }

  // Günlük hedef güncelleme
  void updateDailyGoal(double goal) {
    _dailyGoal = goal;
    notifyListeners();
  }

  // Güne sıfırlama (yeni güne geçişte)
  void resetDay() {
    _todayIntake = 0.0;
    _todayIntakes.clear();
    notifyListeners();
  }

  // Su alımını geri alma
  void removeWaterIntake(int index) {
    if (index < _todayIntakes.length) {
      _todayIntake -= _todayIntakes[index].amount;
      _todayIntakes.removeAt(index);
      notifyListeners();
    }
  }
}

/// Su alımı modeli
class WaterIntake {
  final double amount;
  final DateTime timestamp;

  WaterIntake({required this.amount, required this.timestamp});
}
