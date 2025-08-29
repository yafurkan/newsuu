import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/user_provider.dart';
import '../../../data/models/user_profile.dart';
import 'ob_weight_screen.dart';
import 'ob_height_screen.dart';
import 'ob_gender_screen.dart';
import 'ob_activity_screen.dart';
import 'ob_goals_screen.dart';
import 'ob_veggies_screen.dart';
import 'ob_sugary_screen.dart';
import 'ob_summary_screen.dart';

/// Ana onboarding navigator ekranı
/// Tüm onboarding adımlarını yönetir
class OnboardingNavigator extends StatefulWidget {
  final bool isEditing;
  
  const OnboardingNavigator({super.key, this.isEditing = false});

  @override
  State<OnboardingNavigator> createState() => _OnboardingNavigatorState();
}

class _OnboardingNavigatorState extends State<OnboardingNavigator> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = OnboardingProvider();
        
        // Eğer düzenleme modundaysa mevcut profil verilerini yükle
        if (widget.isEditing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadExistingProfile(context, provider);
          });
        }
        
        return provider;
      },
      child: Consumer<OnboardingProvider>(
        builder: (context, provider, child) {
          return WillPopScope(
            onWillPop: () async {
              // Geri tuşuna basıldığında önceki adıma git
              if (provider.currentStep > 0) {
                provider.back();
                return false; // Ekrandan çıkma
              }
              return true; // İlk adımda ise çıkışa izin ver
            },
            child: _buildCurrentScreen(provider.currentStep),
          );
        },
      ),
    );
  }

  void _loadExistingProfile(BuildContext context, OnboardingProvider provider) {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Mevcut UserProvider verilerini UserProfile formatına dönüştür
      final existingProfile = UserProfile(
        id: '',
        firstName: userProvider.firstName,
        lastName: userProvider.lastName,
        email: '',
        age: userProvider.age,
        weightKg: userProvider.weight,
        heightCm: userProvider.height,
        gender: userProvider.gender == 'male' ? Gender.male : 
               userProvider.gender == 'female' ? Gender.female : Gender.undisclosed,
        activity: userProvider.activityLevel == 'low' ? ActivityLevel.low :
                 userProvider.activityLevel == 'high' ? ActivityLevel.high : ActivityLevel.medium,
        goals: {}, // Varsayılan boş
        veggies: VeggieFreq.rare, // Varsayılan
        sugary: SugaryFreq.almostNever, // Varsayılan
        unitPreferenceWeight: 'kg',
        unitPreferenceHeight: 'cm',
        dailyGoalMl: userProvider.dailyWaterGoal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      provider.loadFromProfile(existingProfile);
    } catch (e) {
      // Hata durumunda varsayılan değerlerle devam et
      print('Profil yükleme hatası: $e');
    }
  }

  Widget _buildCurrentScreen(int step) {
    switch (step) {
      case 0:
        return const ObWeightScreen();
      case 1:
        return const ObHeightScreen();
      case 2:
        return const ObGenderScreen();
      case 3:
        return const ObActivityScreen();
      case 4:
        return const ObGoalsScreen();
      case 5:
        return const ObVeggiesScreen();
      case 6:
        return const ObSugaryScreen();
      case 7:
        return const ObSummaryScreen();
      default:
        return const ObWeightScreen(); // Fallback
    }
  }
}

/// Onboarding wrapper - mevcut kullanıcı kontrolü ile
class OnboardingWrapper extends StatelessWidget {
  final Widget child;
  final bool forceOnboarding;

  const OnboardingWrapper({
    super.key,
    required this.child,
    this.forceOnboarding = false,
  });

  @override
  Widget build(BuildContext context) {
    // Burada mevcut kullanıcının onboarding'i tamamlayıp tamamlamadığını kontrol edebilirsiniz
    // Örneğin: SharedPreferences, Firebase Auth, vb.
    
    if (forceOnboarding) {
      return const OnboardingNavigator();
    }
    
    return child;
  }
}

/// Onboarding tamamlama callback'i
typedef OnboardingCompleteCallback = void Function();

/// Onboarding ile entegre ana widget
class OnboardingIntegratedApp extends StatefulWidget {
  final Widget homeScreen;
  final OnboardingCompleteCallback? onOnboardingComplete;

  const OnboardingIntegratedApp({
    super.key,
    required this.homeScreen,
    this.onOnboardingComplete,
  });

  @override
  State<OnboardingIntegratedApp> createState() => _OnboardingIntegratedAppState();
}

class _OnboardingIntegratedAppState extends State<OnboardingIntegratedApp> {
  bool _isOnboardingComplete = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    // Burada onboarding durumunu kontrol edin
    // Örneğin: SharedPreferences'dan okuma
    // final prefs = await SharedPreferences.getInstance();
    // final isComplete = prefs.getBool('onboarding_complete') ?? false;
    
    // Şimdilik false olarak ayarlıyoruz (test için)
    setState(() {
      _isOnboardingComplete = false;
    });
  }

  void _onOnboardingComplete() {
    setState(() {
      _isOnboardingComplete = true;
    });
    widget.onOnboardingComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOnboardingComplete) {
      return ChangeNotifierProvider(
        create: (context) => OnboardingProvider(),
        child: Consumer<OnboardingProvider>(
          builder: (context, provider, child) {
            return WillPopScope(
              onWillPop: () async {
                if (provider.currentStep > 0) {
                  provider.back();
                  return false;
                }
                return true;
              },
              child: _buildCurrentScreen(provider.currentStep, provider),
            );
          },
        ),
      );
    }
    
    return widget.homeScreen;
  }

  Widget _buildCurrentScreen(int step, OnboardingProvider provider) {
    Widget screen;
    
    switch (step) {
      case 0:
        screen = const ObWeightScreen();
        break;
      case 1:
        screen = const ObHeightScreen();
        break;
      case 2:
        screen = const ObGenderScreen();
        break;
      case 3:
        screen = const ObActivityScreen();
        break;
      case 4:
        screen = const ObGoalsScreen();
        break;
      case 5:
        screen = const ObVeggiesScreen();
        break;
      case 6:
        screen = const ObSugaryScreen();
        break;
      case 7:
        screen = OnboardingCompletionWrapper(
          child: const ObSummaryScreen(),
          onComplete: _onOnboardingComplete,
        );
        break;
      default:
        screen = const ObWeightScreen();
    }
    
    return screen;
  }
}

/// Onboarding tamamlama wrapper'ı
class OnboardingCompletionWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback onComplete;

  const OnboardingCompletionWrapper({
    super.key,
    required this.child,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        // Provider'ın complete metodunu override ediyoruz
        return _OnboardingCompletionHandler(
          provider: provider,
          onComplete: onComplete,
          child: this.child,
        );
      },
    );
  }
}

class _OnboardingCompletionHandler extends StatefulWidget {
  final OnboardingProvider provider;
  final VoidCallback onComplete;
  final Widget child;

  const _OnboardingCompletionHandler({
    required this.provider,
    required this.onComplete,
    required this.child,
  });

  @override
  State<_OnboardingCompletionHandler> createState() => _OnboardingCompletionHandlerState();
}

class _OnboardingCompletionHandlerState extends State<_OnboardingCompletionHandler> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Onboarding durumu enum'u
enum OnboardingStatus {
  notStarted,
  inProgress,
  completed,
}

/// Onboarding durum yöneticisi
class OnboardingStatusManager {
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyOnboardingStep = 'onboarding_step';
  
  /// Onboarding tamamlandı mı?
  static Future<bool> isOnboardingComplete() async {
    // SharedPreferences kullanımı
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getBool(_keyOnboardingComplete) ?? false;
    
    // Şimdilik false döndürüyoruz
    return false;
  }
  
  /// Onboarding'i tamamlandı olarak işaretle
  static Future<void> markOnboardingComplete() async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool(_keyOnboardingComplete, true);
    // await prefs.remove(_keyOnboardingStep); // Adım bilgisini temizle
  }
  
  /// Mevcut onboarding adımını kaydet
  static Future<void> saveCurrentStep(int step) async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setInt(_keyOnboardingStep, step);
  }
  
  /// Kaydedilmiş onboarding adımını al
  static Future<int> getSavedStep() async {
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getInt(_keyOnboardingStep) ?? 0;
    
    return 0;
  }
  
  /// Onboarding verilerini temizle
  static Future<void> clearOnboardingData() async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove(_keyOnboardingComplete);
    // await prefs.remove(_keyOnboardingStep);
  }
  
  /// Onboarding durumunu al
  static Future<OnboardingStatus> getOnboardingStatus() async {
    final isComplete = await isOnboardingComplete();
    if (isComplete) {
      return OnboardingStatus.completed;
    }
    
    final savedStep = await getSavedStep();
    if (savedStep > 0) {
      return OnboardingStatus.inProgress;
    }
    
    return OnboardingStatus.notStarted;
  }
}
