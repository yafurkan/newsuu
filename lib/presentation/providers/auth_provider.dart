import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/cloud_sync_service.dart';
import '../../data/models/user_model.dart';

/// Authentication durumunu yöneten Provider
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final CloudSyncService _cloudSyncService = CloudSyncService();

  User? _user;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _user != null;

  AuthProvider() {
    // Firebase Auth state değişikliklerini dinle
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  /// Hata mesajını temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Loading durumunu ayarla
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Hata mesajını ayarla
  void _setError(String error) {
    _errorMessage = error;
    _setLoading(false);
  }

  /// Google ile giriş yap
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      clearError();

      final user = await _authService.signInWithGoogle();
      if (user != null) {
        await _loadUserProfile();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Google ile giriş yapılırken hata oluştu: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Çıkış yap
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _user = null;
      _userProfile = null;
    } catch (e) {
      _setError('Çıkış yapılırken hata oluştu: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Kullanıcı profilini yükle
  Future<void> _loadUserProfile() async {
    if (_user == null) return;

    try {
      // Önce Firestore'dan profil bilgilerini al
      _userProfile = await _cloudSyncService.getUserProfile();

      // Eğer Firestore'da profil yoksa, Firebase Auth bilgilerinden oluştur
      if (_userProfile == null && _user != null) {
        final displayName = _user!.displayName ?? '';
        final nameParts = displayName.split(' ');

        _userProfile = UserModel(
          firstName: nameParts.isNotEmpty ? nameParts.first : 'Kullanıcı',
          lastName: nameParts.length > 1 ? nameParts.skip(1).join(' ') : '',
          email: _user!.email,
          photoUrl: _user!.photoURL,
          age: 25, // Varsayılan değer
          weight: 70.0, // Varsayılan değer
          height: 170.0, // Varsayılan değer
          gender: 'male', // Varsayılan değer
          activityLevel: 'Orta',
          dailyWaterGoal: 2000.0, // Varsayılan 2L
          wakeUpTime: '07:00',
          sleepTime: '23:00',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Yeni profili Firestore'a kaydet
        await _cloudSyncService.syncUserProfile(_userProfile!);
      }

      notifyListeners();
    } catch (e) {
      print('Kullanıcı profili yüklenemedi: $e');
    }
  }

  /// Kullanıcı profilini güncelle
  Future<void> updateUserProfile(UserModel updatedProfile) async {
    try {
      _setLoading(true);

      // Firestore'a kaydet
      await _cloudSyncService.syncUserProfile(updatedProfile);

      // Local state'i güncelle
      _userProfile = updatedProfile;
      notifyListeners();
    } catch (e) {
      _setError('Profil güncellenirken hata oluştu: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Hesabı sil
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      clearError();

      final success = await _authService.deleteUserAccount();
      if (success) {
        _user = null;
        _userProfile = null;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Hesap silinirken hata oluştu: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Tüm verileri Firestore'a senkronize et
  Future<void> syncAllData() async {
    if (!isSignedIn) return;

    try {
      _setLoading(true);

      // Burada diğer provider'lardan verileri alıp sync edeceğiz
      // Şimdilik sadece profil sync ediyoruz
      if (_userProfile != null) {
        await _cloudSyncService.syncUserProfile(_userProfile!);
      }
    } catch (e) {
      _setError('Veri senkronizasyonu sırasında hata oluştu: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
}
