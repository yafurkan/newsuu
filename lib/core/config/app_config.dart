import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  // Firebase Configuration - flutter_dotenv kullanarak
  String get firebaseApiKeyWeb => dotenv.env['FIREBASE_API_KEY_WEB'] ?? '';
  String get firebaseProjectIdWeb => dotenv.env['FIREBASE_PROJECT_ID_WEB'] ?? '';
  String get firebaseAppIdWeb => dotenv.env['FIREBASE_APP_ID_WEB'] ?? '';
  String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  String get firebaseStorageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  
  // Getters
  String get environment => _environment;
  bool get isDebugMode => _debugMode || kDebugMode;
  bool get isProduction => _environment == 'production';
  bool get isDevelopment => _environment == 'development';
  
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
  
  // Environment validation
  bool get hasValidFirebaseConfig => 
    firebaseApiKeyWeb.isNotEmpty && 
    firebaseProjectIdWeb.isNotEmpty && 
    firebaseAppIdWeb.isNotEmpty;
  
  // Debug Information
  Map<String, dynamic> get debugInfo => {
    'environment': environment,
    'isDebugMode': isDebugMode,
    'isProduction': isProduction,
    'isDevelopment': isDevelopment,
    'enableLogging': enableLogging,
    'enableCrashReporting': enableCrashReporting,
    'enableAnalytics': enableAnalytics,
    'hasValidFirebaseConfig': hasValidFirebaseConfig,
  };
  
  @override
  String toString() {
    if (kDebugMode) {
      return 'AppConfig(environment: $environment, debugMode: $isDebugMode, firebaseConfigValid: $hasValidFirebaseConfig)';
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