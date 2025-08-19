import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Güvenlik doğrulama servisi
/// Uygulama başlangıcında güvenlik kontrollerini yapar
class SecurityValidator {
  static final SecurityValidator _instance = SecurityValidator._internal();
  factory SecurityValidator() => _instance;
  SecurityValidator._internal();

  /// Güvenlik kontrollerini başlat
  static Future<SecurityValidationResult> validateSecurity() async {
    final validator = SecurityValidator();
    
    final results = <SecurityCheck>[];
    
    // Firebase konfigürasyon kontrolü
    results.add(await validator._validateFirebaseConfig());
    
    // Environment variables kontrolü
    results.add(await validator._validateEnvironmentVariables());
    
    // Debug mode kontrolü
    results.add(await validator._validateDebugMode());
    
    // Network güvenlik kontrolü
    results.add(await validator._validateNetworkSecurity());
    
    return SecurityValidationResult(results);
  }

  /// Firebase konfigürasyonunu kontrol et
  Future<SecurityCheck> _validateFirebaseConfig() async {
    try {
      final config = AppConfig();
      
      // API anahtarlarının boş olup olmadığını kontrol et
      if (config.firebaseApiKeyWeb.isEmpty) {
        return SecurityCheck(
          name: 'Firebase Configuration',
          status: SecurityStatus.error,
          message: 'Firebase API anahtarları environment variables\'dan yüklenemedi',
          recommendation: '.env dosyasını kontrol edin ve FIREBASE_API_KEY_WEB değişkenini ayarlayın',
        );
      }
      
      // API anahtarının geçerli format olup olmadığını kontrol et
      if (!config.firebaseApiKeyWeb.startsWith('AIza')) {
        return SecurityCheck(
          name: 'Firebase Configuration',
          status: SecurityStatus.warning,
          message: 'Firebase API anahtarı geçersiz format',
          recommendation: 'Firebase Console\'dan doğru API anahtarını alın',
        );
      }
      
      return SecurityCheck(
        name: 'Firebase Configuration',
        status: SecurityStatus.success,
        message: 'Firebase konfigürasyonu güvenli şekilde yüklendi',
      );
    } catch (e) {
      return SecurityCheck(
        name: 'Firebase Configuration',
        status: SecurityStatus.error,
        message: 'Firebase konfigürasyon hatası: $e',
        recommendation: 'Firebase ayarlarını kontrol edin',
      );
    }
  }

  /// Environment variables kontrolü
  Future<SecurityCheck> _validateEnvironmentVariables() async {
    const requiredEnvVars = [
      'FIREBASE_API_KEY_WEB',
      'FIREBASE_PROJECT_ID_WEB',
      'FIREBASE_APP_ID_WEB',
    ];
    
    final missingVars = <String>[];
    
    for (final envVar in requiredEnvVars) {
      final value = _getEnvironmentVariable(envVar);
      if (value.isEmpty) {
        missingVars.add(envVar);
      }
    }
    
    if (missingVars.isNotEmpty) {
      return SecurityCheck(
        name: 'Environment Variables',
        status: SecurityStatus.error,
        message: 'Eksik environment variables: ${missingVars.join(', ')}',
        recommendation: '.env dosyasına eksik değişkenleri ekleyin',
      );
    }
    
    return SecurityCheck(
      name: 'Environment Variables',
      status: SecurityStatus.success,
      message: 'Tüm gerekli environment variables mevcut',
    );
  }

  /// Debug mode kontrolü
  Future<SecurityCheck> _validateDebugMode() async {
    final config = AppConfig();
    
    if (config.isProduction && kDebugMode) {
      return SecurityCheck(
        name: 'Debug Mode',
        status: SecurityStatus.warning,
        message: 'Production ortamında debug mode aktif',
        recommendation: 'Release build kullanın: flutter build --release',
      );
    }
    
    if (config.isProduction && config.enableLogging) {
      return SecurityCheck(
        name: 'Debug Mode',
        status: SecurityStatus.warning,
        message: 'Production ortamında logging aktif',
        recommendation: 'Production için logging\'i kapatın',
      );
    }
    
    return SecurityCheck(
      name: 'Debug Mode',
      status: SecurityStatus.success,
      message: 'Debug mode ayarları uygun',
    );
  }

  /// Network güvenlik kontrolü
  Future<SecurityCheck> _validateNetworkSecurity() async {
    final config = AppConfig();
    
    if (config.isProduction && !config.enableSSLPinning) {
      return SecurityCheck(
        name: 'Network Security',
        status: SecurityStatus.warning,
        message: 'Production ortamında SSL pinning kapalı',
        recommendation: 'SSL pinning\'i aktifleştirin',
      );
    }
    
    return SecurityCheck(
      name: 'Network Security',
      status: SecurityStatus.success,
      message: 'Network güvenlik ayarları uygun',
    );
  }

  /// Environment variable'ı güvenli şekilde al
  String _getEnvironmentVariable(String key) {
    switch (key) {
      case 'FIREBASE_API_KEY_WEB':
        return const String.fromEnvironment('FIREBASE_API_KEY_WEB', defaultValue: '');
      case 'FIREBASE_PROJECT_ID_WEB':
        return const String.fromEnvironment('FIREBASE_PROJECT_ID_WEB', defaultValue: '');
      case 'FIREBASE_APP_ID_WEB':
        return const String.fromEnvironment('FIREBASE_APP_ID_WEB', defaultValue: '');
      default:
        return '';
    }
  }
}

/// Güvenlik kontrolü sonucu
class SecurityValidationResult {
  final List<SecurityCheck> checks;
  
  SecurityValidationResult(this.checks);
  
  /// Tüm kontroller başarılı mı?
  bool get isValid => checks.every((check) => check.status != SecurityStatus.error);
  
  /// Uyarı var mı?
  bool get hasWarnings => checks.any((check) => check.status == SecurityStatus.warning);
  
  /// Hata var mı?
  bool get hasErrors => checks.any((check) => check.status == SecurityStatus.error);
  
  /// Hata sayısı
  int get errorCount => checks.where((check) => check.status == SecurityStatus.error).length;
  
  /// Uyarı sayısı
  int get warningCount => checks.where((check) => check.status == SecurityStatus.warning).length;
  
  /// Başarı sayısı
  int get successCount => checks.where((check) => check.status == SecurityStatus.success).length;
  
  /// Özet rapor
  String get summary {
    return 'Güvenlik Kontrolü: $successCount başarılı, $warningCount uyarı, $errorCount hata';
  }
  
  /// Detaylı rapor
  String get detailedReport {
    final buffer = StringBuffer();
    buffer.writeln('🔒 GÜVENLİK RAPORU');
    buffer.writeln('=' * 50);
    buffer.writeln(summary);
    buffer.writeln();
    
    for (final check in checks) {
      final icon = check.status.icon;
      buffer.writeln('$icon ${check.name}: ${check.message}');
      if (check.recommendation != null) {
        buffer.writeln('   💡 Öneri: ${check.recommendation}');
      }
      buffer.writeln();
    }
    
    return buffer.toString();
  }
}

/// Güvenlik kontrolü
class SecurityCheck {
  final String name;
  final SecurityStatus status;
  final String message;
  final String? recommendation;
  
  SecurityCheck({
    required this.name,
    required this.status,
    required this.message,
    this.recommendation,
  });
}

/// Güvenlik durumu
enum SecurityStatus {
  success,
  warning,
  error,
}

/// Güvenlik durumu extension
extension SecurityStatusExtension on SecurityStatus {
  String get icon {
    switch (this) {
      case SecurityStatus.success:
        return '✅';
      case SecurityStatus.warning:
        return '⚠️';
      case SecurityStatus.error:
        return '❌';
    }
  }
  
  String get name {
    switch (this) {
      case SecurityStatus.success:
        return 'Başarılı';
      case SecurityStatus.warning:
        return 'Uyarı';
      case SecurityStatus.error:
        return 'Hata';
    }
  }
}