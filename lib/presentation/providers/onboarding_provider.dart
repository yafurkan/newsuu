import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/hydration_factors.dart';
import '../../domain/services/hydration_goal_service.dart';
import '../../core/utils/debug_logger.dart';

/// Onboarding wizard state ve validasyon provider'ı
class OnboardingProvider extends ChangeNotifier {
  // Wizard state
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Form verileri
  double _weightKg = 70.0;
  double _heightCm = 170.0;
  Gender _gender = Gender.undisclosed;
  ActivityLevel _activity = ActivityLevel.medium;
  Set<String> _goals = {};
  VeggieFreq _veggies = VeggieFreq.rare;
  SugaryFreq _sugary = SugaryFreq.almostNever;

  // UI preferences
  int _weightUnitIndex = 0; // 0: kg, 1: lb
  int _heightUnitIndex = 0; // 0: cm, 1: ft/in
  
  // Dual height picker için
  int _heightFeet = 5;
  int _heightInches = 7;

  // Toplam adım sayısı
  static const int _totalSteps = 8;

  // Getters
  int get currentStep => _currentStep;
  int get totalSteps => _totalSteps;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Form data getters
  double get weightKg => _weightKg;
  double get heightCm => _heightCm;
  Gender get gender => _gender;
  ActivityLevel get activity => _activity;
  Set<String> get goals => _goals;
  VeggieFreq get veggies => _veggies;
  SugaryFreq get sugary => _sugary;

  // UI state getters
  int get weightUnitIndex => _weightUnitIndex;
  int get heightUnitIndex => _heightUnitIndex;
  bool get isKg => _weightUnitIndex == 0;
  bool get isCm => _heightUnitIndex == 0;
  int get heightFeet => _heightFeet;
  int get heightInches => _heightInches;

  // Display values (UI için dönüştürülmüş)
  double get displayWeight => isKg ? _weightKg : UnitConversions.kgToLb(_weightKg);
  double get displayHeight => isCm ? _heightCm : _heightCm; // feet/inch için ayrı getter var

  /// Ağırlık birim değişimi
  void onWeightUnitChanged(int index) {
    if (index != _weightUnitIndex) {
      _weightUnitIndex = index;
      HapticFeedback.selectionClick();
      notifyListeners();
      
      DebugLogger.info(
        '⚖️ Ağırlık birimi değişti: ${isKg ? 'kg' : 'lb'}',
        tag: 'ONBOARDING',
      );
    }
  }

  /// Boy birim değişimi
  void onHeightUnitChanged(int index) {
    if (index != _heightUnitIndex) {
      _heightUnitIndex = index;
      
      // cm'den feet/inch'e dönüştür
      if (!isCm) {
        final feetInches = UnitConversions.cmToFeetInches(_heightCm);
        _heightFeet = feetInches['feet']!;
        _heightInches = feetInches['inches']!;
      }
      
      HapticFeedback.selectionClick();
      notifyListeners();
      
      DebugLogger.info(
        '📏 Boy birimi değişti: ${isCm ? 'cm' : 'ft/in'}',
        tag: 'ONBOARDING',
      );
    }
  }

  /// Ağırlık değeri güncelle (her zaman kg olarak sakla)
  void setWeight(double weight) {
    final newWeightKg = isKg ? weight : UnitConversions.lbToKg(weight);
    if (newWeightKg != _weightKg) {
      _weightKg = newWeightKg;
      notifyListeners();
    }
  }

  /// Boy değeri güncelle (her zaman cm olarak sakla)
  void setHeight(double height) {
    if (isCm) {
      _heightCm = height;
    } else {
      // Bu durumda height parametresi kullanılmaz, feet/inches kullanılır
      _heightCm = UnitConversions.feetInchesToCm(_heightFeet, _heightInches);
    }
    notifyListeners();
  }

  /// Feet/Inches güncelle
  void setHeightFeetInches(Map<String, int> values) {
    _heightFeet = values['feet'] ?? _heightFeet;
    _heightInches = values['inches'] ?? _heightInches;
    _heightCm = UnitConversions.feetInchesToCm(_heightFeet, _heightInches);
    notifyListeners();
  }

  /// Cinsiyet seç
  void setGender(Gender gender) {
    if (gender != _gender) {
      _gender = gender;
      notifyListeners();
      
      DebugLogger.info(
        '👤 Cinsiyet seçildi: ${gender.displayName}',
        tag: 'ONBOARDING',
      );
    }
  }

  /// Aktivite seviyesi seç
  void setActivity(ActivityLevel activity) {
    if (activity != _activity) {
      _activity = activity;
      notifyListeners();
      
      DebugLogger.info(
        '🏃 Aktivite seviyesi seçildi: ${activity.displayName}',
        tag: 'ONBOARDING',
      );
    }
  }

  /// Hedef toggle
  void toggleGoal(String goalId) {
    final newGoals = Set<String>.from(_goals);
    if (newGoals.contains(goalId)) {
      newGoals.remove(goalId);
    } else {
      newGoals.add(goalId);
    }
    _goals = newGoals;
    notifyListeners();
    
    DebugLogger.info(
      '🎯 Hedefler güncellendi: ${_goals.join(', ')}',
      tag: 'ONBOARDING',
    );
  }

  /// Sebze sıklığı seç
  void setVeggies(VeggieFreq veggies) {
    if (veggies != _veggies) {
      _veggies = veggies;
      notifyListeners();
      
      DebugLogger.info(
        '🥬 Sebze sıklığı seçildi: ${veggies.displayName}',
        tag: 'ONBOARDING',
      );
    }
  }

  /// Şekerli içecek sıklığı seç
  void setSugary(SugaryFreq sugary) {
    if (sugary != _sugary) {
      _sugary = sugary;
      notifyListeners();
      
      DebugLogger.info(
        '🥤 Şekerli içecek sıklığı seçildi: ${sugary.displayName}',
        tag: 'ONBOARDING',
      );
    }
  }

  /// Validasyon kontrolleri
  bool get isWeightValid => _weightKg >= 30 && _weightKg <= 200;
  bool get isHeightValid => _heightCm >= 120 && _heightCm <= 220;
  bool get isGenderValid => true; // Tüm seçenekler geçerli
  bool get isActivityValid => true; // Tüm seçenekler geçerli
  bool get isGoalsValid => true; // Hedef seçmek opsiyonel
  bool get isVeggiesValid => true; // Tüm seçenekler geçerli
  bool get isSugaryValid => true; // Tüm seçenekler geçerli

  /// Mevcut adım için validasyon
  bool get isCurrentStepValid {
    switch (_currentStep) {
      case 0: return isWeightValid;
      case 1: return isHeightValid;
      case 2: return isGenderValid;
      case 3: return isActivityValid;
      case 4: return isGoalsValid;
      case 5: return isVeggiesValid;
      case 6: return isSugaryValid;
      case 7: return true; // Özet ekranı
      default: return false;
    }
  }

  /// Sonraki adıma geç
  Future<void> next() async {
    if (!isCurrentStepValid) {
      _setError('Lütfen gerekli alanları doldurun');
      return;
    }

    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      _clearError();
      notifyListeners();
      
      DebugLogger.info(
        '➡️ Sonraki adıma geçildi: ${_currentStep + 1}/$totalSteps',
        tag: 'ONBOARDING',
      );
    }
  }

  /// Önceki adıma dön
  void back() {
    if (_currentStep > 0) {
      _currentStep--;
      _clearError();
      notifyListeners();
      
      DebugLogger.info(
        '⬅️ Önceki adıma dönüldü: ${_currentStep + 1}/$totalSteps',
        tag: 'ONBOARDING',
      );
    }
  }

  /// Belirli adıma git
  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      _clearError();
      notifyListeners();
      
      DebugLogger.info(
        '🎯 Adıma gidildi: ${_currentStep + 1}/$totalSteps',
        tag: 'ONBOARDING',
      );
    }
  }

  /// Onboarding'i tamamla
  Future<UserProfile> complete() async {
    try {
      _setLoading(true);
      _clearError();

      // Profil oluştur
      final profile = UserProfile(
        id: '', // Auth service tarafından set edilecek
        firstName: '', // Daha sonra doldurulacak
        lastName: '', // Daha sonra doldurulacak
        email: '', // Auth service'den gelecek
        age: 25, // Varsayılan, daha sonra güncellenebilir
        weightKg: _weightKg,
        heightCm: _heightCm,
        gender: _gender,
        activity: _activity,
        goals: _goals,
        veggies: _veggies,
        sugary: _sugary,
        unitPreferenceWeight: isKg ? 'kg' : 'lb',
        unitPreferenceHeight: isCm ? 'cm' : 'ft_in',
        dailyGoalMl: 0, // Hesaplanacak
        isFirstTime: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Günlük hedefi hesapla
      final goalMl = HydrationGoalService.computeDailyGoalMl(profile);
      final finalProfile = profile.copyWith(dailyGoalMl: goalMl.toDouble());

      DebugLogger.info(
        '✅ Onboarding tamamlandı. Hedef: ${goalMl}ml',
        tag: 'ONBOARDING',
      );

      return finalProfile;

    } catch (e) {
      _setError('Profil oluşturma hatası: $e');
      DebugLogger.info(
        '❌ Onboarding tamamlama hatası: $e',
        tag: 'ONBOARDING',
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Hesaplanan günlük hedefi al (önizleme için)
  int getCalculatedGoal() {
    final tempProfile = UserProfile(
      id: '',
      firstName: '',
      lastName: '',
      email: '',
      age: 25,
      weightKg: _weightKg,
      heightCm: _heightCm,
      gender: _gender,
      activity: _activity,
      goals: _goals,
      veggies: _veggies,
      sugary: _sugary,
      dailyGoalMl: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return HydrationGoalService.computeDailyGoalMl(tempProfile);
  }

  /// Profil tamamlama yüzdesini al
  double getCompletionPercentage() {
    final tempProfile = UserProfile(
      id: '',
      firstName: '',
      lastName: '',
      email: '',
      age: 25,
      weightKg: _weightKg,
      heightCm: _heightCm,
      gender: _gender,
      activity: _activity,
      goals: _goals,
      veggies: _veggies,
      sugary: _sugary,
      dailyGoalMl: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return HydrationGoalService.getProfileCompletionPercentage(tempProfile);
  }

  /// State'i sıfırla
  void reset() {
    _currentStep = 0;
    _weightKg = 70.0;
    _heightCm = 170.0;
    _gender = Gender.undisclosed;
    _activity = ActivityLevel.medium;
    _goals.clear();
    _veggies = VeggieFreq.rare;
    _sugary = SugaryFreq.almostNever;
    _weightUnitIndex = 0;
    _heightUnitIndex = 0;
    _heightFeet = 5;
    _heightInches = 7;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
    
    DebugLogger.info('🔄 Onboarding state sıfırlandı', tag: 'ONBOARDING');
  }

  /// Mevcut profil ile state'i doldur (düzenleme modu için)
  void loadFromProfile(UserProfile profile) {
    _weightKg = profile.weightKg;
    _heightCm = profile.heightCm;
    _gender = profile.gender;
    _activity = profile.activity;
    _goals = Set<String>.from(profile.goals);
    _veggies = profile.veggies;
    _sugary = profile.sugary;
    
    // UI preferences
    _weightUnitIndex = profile.unitPreferenceWeight == 'lb' ? 1 : 0;
    _heightUnitIndex = profile.unitPreferenceHeight == 'ft_in' ? 1 : 0;
    
    if (!isCm) {
      final feetInches = UnitConversions.cmToFeetInches(_heightCm);
      _heightFeet = feetInches['feet']!;
      _heightInches = feetInches['inches']!;
    }
    
    notifyListeners();
    
    DebugLogger.info('📝 Profil yüklendi: ${profile.fullName}', tag: 'ONBOARDING');
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
