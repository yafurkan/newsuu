import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../core/utils/debug_logger.dart';
import 'badge_provider.dart';

/// Authentication state management provider
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSignedIn = false;
  String? _userId;
  String? _userEmail;

  // Callback for clearing other providers on logout
  VoidCallback? _onSignOutCallback;
  
  // Badge provider reference
  BadgeProvider? _badgeProvider;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _isSignedIn;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  bool get isEmailVerified => _authService.isEmailVerified;

  // Callback setter
  void setSignOutCallback(VoidCallback callback) {
    _onSignOutCallback = callback;
  }
  
  /// Badge provider'ı ayarla
  void setBadgeProvider(BadgeProvider badgeProvider) {
    _badgeProvider = badgeProvider;
  }

  AuthProvider() {
    _checkAuthState();
  }

  /// Check initial auth state
  void _checkAuthState() {
    _isSignedIn = _authService.isSignedIn;
    _userId = _authService.currentUserId;
    _userEmail = _authService.currentUserEmail;
    notifyListeners();
  }

  /// Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (success) {
        _isSignedIn = true;
        _userId = _authService.currentUserId;
        _userEmail = _authService.currentUserEmail;
        DebugLogger.success(
          'AuthProvider: Giriş başarılı',
          tag: 'AUTH_PROVIDER',
        );
        
        // Kullanıcı rozetlerini başlat
        _initializeUserBadges();
      }

      return success;
    } catch (e) {
      _setError('Giriş yapılamadı: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up with email and password
  Future<bool> signUp(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _authService.signUpWithEmailAndPassword(
        email,
        password,
      );

      if (success) {
        _isSignedIn = true;
        _userId = _authService.currentUserId;
        _userEmail = _authService.currentUserEmail;
        DebugLogger.success(
          'AuthProvider: Kayıt başarılı',
          tag: 'AUTH_PROVIDER',
        );
        
        // Yeni kullanıcı için rozetleri başlat
        _initializeUserBadges();
      }

      return success;
    } catch (e) {
      _setError('Kayıt oluşturulamadı: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signOut();

      _isSignedIn = false;
      _userId = null;
      _userEmail = null;

      DebugLogger.success('AuthProvider: Çıkış başarılı', tag: 'AUTH_PROVIDER');

      // Diğer provider'ları temizle
      _onSignOutCallback?.call();

      // Çıkış işlemi tamamlandıktan sonra navigation'ı tetikle
      notifyListeners();
    } catch (e) {
      _setError('Çıkış yapılamadı: $e');
      DebugLogger.error(
        'AuthProvider: Çıkış hatası - $e',
        tag: 'AUTH_PROVIDER',
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError('Şifre sıfırlama e-postası gönderilemedi: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.deleteAccount();

      _isSignedIn = false;
      _userId = null;
      _userEmail = null;

      return true;
    } catch (e) {
      _setError('Hesap silinemedi: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null) {
        _isSignedIn = true;
        _userId = _authService.currentUserId;
        _userEmail = _authService.currentUserEmail;
        DebugLogger.success(
          'AuthProvider: Google ile giriş başarılı',
          tag: 'AUTH_PROVIDER',
        );
        
        // Google kullanıcısı için rozetleri başlat
        _initializeUserBadges();
        
        return true;
      }

      return false;
    } catch (e) {
      _setError('Google ile giriş yapılamadı: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// E-posta doğrulama gönder
  Future<bool> sendEmailVerification() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.sendEmailVerification();
      DebugLogger.success(
        'AuthProvider: E-posta doğrulama gönderildi',
        tag: 'AUTH_PROVIDER',
      );
      return true;
    } catch (e) {
      _setError('E-posta doğrulama gönderilemedi: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// E-posta doğrulama durumunu yenile
  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
      notifyListeners();
    } catch (e) {
      DebugLogger.error('Kullanıcı yenileme hatası: $e', tag: 'AUTH_PROVIDER');
    }
  }

  /// Check if user is signed in
  void checkAuthStatus() {
    _checkAuthState();
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

  /// Clear error message
  void clearError() {
    _clearError();
    notifyListeners();
  }
  
  /// Kullanıcı rozetlerini başlat
  void _initializeUserBadges() {
    if (_badgeProvider != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _badgeProvider!.initializeUserBadges();
      });
    }
  }
}
