import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/utils/debug_logger.dart';

/// Deep link yönetimi servisi
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  static const MethodChannel _channel = MethodChannel('flutter/navigation');
  
  /// Deep link dinleyicisi başlat
  void initialize() {
    try {
      // Initial link kontrol et (uygulama kapalıyken açıldıysa)
      _handleInitialLink();
      
      // Incoming link dinle (uygulama açıkken link gelirse)
      _channel.setMethodCallHandler(_handleMethodCall);
      
      DebugLogger.success('Deep link servisi başlatıldı', tag: 'DEEP_LINK');
    } catch (e) {
      DebugLogger.error('Deep link servisi başlatma hatası: $e', tag: 'DEEP_LINK');
    }
  }

  /// İlk link'i kontrol et
  Future<void> _handleInitialLink() async {
    try {
      // Bu kısım platform-specific implementation gerektirir
      // Şimdilik Firebase Auth'un kendi mekanizmasını kullanacağız
      DebugLogger.info('Initial link kontrol edildi', tag: 'DEEP_LINK');
    } catch (e) {
      DebugLogger.error('Initial link kontrol hatası: $e', tag: 'DEEP_LINK');
    }
  }

  /// Method call handler
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'routeUpdated':
        final String? link = call.arguments;
        if (link != null) {
          await _handleIncomingLink(link);
        }
        break;
      default:
        DebugLogger.warning('Bilinmeyen method call: ${call.method}', tag: 'DEEP_LINK');
    }
  }

  /// Gelen link'i işle
  Future<void> _handleIncomingLink(String link) async {
    try {
      DebugLogger.info('Deep link alındı: $link', tag: 'DEEP_LINK');
      
      final uri = Uri.parse(link);
      
      // Firebase Auth action link'i kontrol et
      if (uri.host == 'sutakip-fcm-app-furkan-da7fe.firebaseapp.com' && 
          uri.path.contains('__/auth/action')) {
        await _handleFirebaseAuthAction(uri);
      }
      // Custom scheme kontrol et
      else if (uri.scheme == 'sutakip') {
        await _handleCustomScheme(uri);
      }
      
    } catch (e) {
      DebugLogger.error('Deep link işleme hatası: $e', tag: 'DEEP_LINK');
    }
  }

  /// Firebase Auth action link'ini işle
  Future<void> _handleFirebaseAuthAction(Uri uri) async {
    try {
      final mode = uri.queryParameters['mode'];
      final oobCode = uri.queryParameters['oobCode'];
      
      DebugLogger.info('Firebase Auth action: $mode', tag: 'DEEP_LINK');
      
      switch (mode) {
        case 'verifyEmail':
          if (oobCode != null) {
            await _handleEmailVerification(oobCode);
          }
          break;
        case 'resetPassword':
          if (oobCode != null) {
            await _handlePasswordReset(oobCode);
          }
          break;
        default:
          DebugLogger.warning('Bilinmeyen auth action: $mode', tag: 'DEEP_LINK');
      }
    } catch (e) {
      DebugLogger.error('Firebase Auth action işleme hatası: $e', tag: 'DEEP_LINK');
    }
  }

  /// E-posta doğrulama işle
  Future<void> _handleEmailVerification(String oobCode) async {
    try {
      // Firebase Auth ile e-posta doğrulama yap
      await FirebaseAuth.instance.applyActionCode(oobCode);
      
      // Kullanıcı bilgilerini yenile
      await FirebaseAuth.instance.currentUser?.reload();
      
      DebugLogger.success('E-posta doğrulama başarılı', tag: 'DEEP_LINK');
      
      // Başarı callback'i tetikle
      _onEmailVerificationSuccess();
      
    } catch (e) {
      DebugLogger.error('E-posta doğrulama hatası: $e', tag: 'DEEP_LINK');
      _onEmailVerificationError(e.toString());
    }
  }

  /// Şifre sıfırlama işle
  Future<void> _handlePasswordReset(String oobCode) async {
    try {
      // Şifre sıfırlama kodu doğrula
      await FirebaseAuth.instance.verifyPasswordResetCode(oobCode);
      
      DebugLogger.success('Şifre sıfırlama kodu doğrulandı', tag: 'DEEP_LINK');
      
      // Şifre sıfırlama sayfasına yönlendir
      _onPasswordResetSuccess(oobCode);
      
    } catch (e) {
      DebugLogger.error('Şifre sıfırlama hatası: $e', tag: 'DEEP_LINK');
      _onPasswordResetError(e.toString());
    }
  }

  /// Custom scheme işle
  Future<void> _handleCustomScheme(Uri uri) async {
    try {
      final path = uri.path.isEmpty ? uri.host : uri.path;
      
      DebugLogger.info('Custom scheme path: $path', tag: 'DEEP_LINK');
      
      switch (path) {
        case 'email-verified':
        case '/email-verified':
          _onEmailVerificationSuccess();
          break;
        case 'password-reset':
        case '/password-reset':
          _onPasswordResetSuccess(uri.queryParameters['code'] ?? '');
          break;
        default:
          DebugLogger.warning('Bilinmeyen custom path: $path', tag: 'DEEP_LINK');
      }
    } catch (e) {
      DebugLogger.error('Custom scheme işleme hatası: $e', tag: 'DEEP_LINK');
    }
  }

  /// E-posta doğrulama başarı callback'leri
  Function()? onEmailVerificationSuccess;
  Function(String error)? onEmailVerificationError;
  Function(String code)? onPasswordResetSuccess;
  Function(String error)? onPasswordResetError;

  void _onEmailVerificationSuccess() {
    onEmailVerificationSuccess?.call();
  }

  void _onEmailVerificationError(String error) {
    onEmailVerificationError?.call(error);
  }

  void _onPasswordResetSuccess(String code) {
    onPasswordResetSuccess?.call(code);
  }

  void _onPasswordResetError(String error) {
    onPasswordResetError?.call(error);
  }

  /// Test deep link
  Future<void> testDeepLink() async {
    await _handleIncomingLink('sutakip://email-verified');
  }
}
