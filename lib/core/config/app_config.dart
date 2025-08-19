import 'package:flutter/foundation.dart';

/// Uygulama konfigürasyon sınıfı
/// Hassas bilgileri güvenli şekilde yönetir
class AppConfig {
  // Singleton pattern
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Environment variables
  static const String _environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'production');
  static const bool _debugMode = bool.fromEnvironment('DEBUG_MODE', defaultValue: false);

  // Firebase Configuration
  static const String _firebaseApiKeyWeb = String.fromEnvironment('FIREBASE_API_KEY_WEB', defaultValue: '');
  static const String _firebaseProjectIdWeb = String.fromEnvironment('FIREBASE_PROJECT_ID_WEB', defaultValue: '');
  
  // Getters
  String get environment => _environment;
  bool get isDebugMode => _debugMode || kDebugMode;
  bool get isProduction => _environment == 'production';
  bool get isDevelopment => _environment == 'development';
  
  // Firebase getters
  String get firebaseApiKeyWeb => _firebaseApiKeyWeb;
  String get firebaseProjectIdWeb => _firebaseProjectIdWeb;
  
  // API Configuration
  String get weatherApiBaseUrl => isProduction 
    ? 'https://api.openweathermap.org/data/2.5'
    : 'https://api.openweathermap.org/data/2.5'; // Test URL'si farklı olabilir
    
  // App Configuration
  Duration get httpTimeout => const Duration(seconds: 30);
  int get maxRetryAttempts => 3;
  
  // Cache Configuration
  Duration get cacheExpiration => const Duration(hours: 1);
  int get maxCacheSize => 100; // MB
  
  // Logging Configuration
  bool get enableLogging => isDebugMode || isDevelopment;
  bool get enableCrashReporting => isProduction;
  
  // Feature Flags
  bool get enableAnalytics => isProduction;
  bool get enablePushNotifications => true;
  bool get enableLocationServices => true;
  
  // Security Configuration
  bool get enableSSLPinning => isProduction;
  bool get enableBiometricAuth => true;
  
  // Debug Information
  Map<String, dynamic> get debugInfo => {
    'environment': environment,
    'isDebugMode': isDebugMode,
    'isProduction': isProduction,
    'isDevelopment': isDevelopment,
    'enableLogging': enableLogging,
    'enableCrashReporting': enableCrashReporting,
    'enableAnalytics': enableAnalytics,
  };
  
  @override
  String toString() {
    if (kDebugMode) {
      return 'AppConfig(environment: $environment, debugMode: $isDebugMode)';
    }
    return 'AppConfig(production)';
  }
}

/// Environment enum
enum Environment {
  development,
  staging,
  production,
}

/// Environment extension
extension EnvironmentExtension on Environment {
  String get name {
    switch (this) {
      case Environment.development:
        return 'development';
      case Environment.staging:
        return 'staging';
      case Environment.production:
        return 'production';
    }
  }
  
  bool get isProduction => this == Environment.production;
  bool get isDevelopment => this == Environment.development;
  bool get isStaging => this == Environment.staging;
}