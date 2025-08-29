import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/debug_logger.dart';
import 'email_service.dart';

/// Firebase Authentication ve Google Sign-In servisi
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Platform bazlı GoogleSignIn yapılandırması
  late final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EmailService _emailService = EmailService();
  
  AuthService() {
    // Platform kontrolü yaparak doğru client ID'yi kullan
    if (Platform.isIOS) {
      _googleSignIn = GoogleSignIn(
        clientId: '36993591963-3sahp73m6m1qqbji114sv2f1j41nan36.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
    } else if (Platform.isAndroid) {
      // Android için Web Client ID kullanılır
      _googleSignIn = GoogleSignIn(
        serverClientId: '36993591963-bjo3cbg8qriqap0ogbr5iqmao1mict0n.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
    } else {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
    }
  }

  /// Mevcut kullaniciyi al
  User? get currentUser => _auth.currentUser;

  /// Authentication durumu stream'i
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Kullanici giris yapmis mi?
  bool get isSignedIn => currentUser != null;

  /// Google ile giris yap
  Future<UserCredential?> signInWithGoogle() async {
    try {
      DebugLogger.info('Google Sign-In başlatılıyor...', tag: 'AUTH');
      
      // iOS için özel kontrol
      DebugLogger.info('Platform kontrolü yapılıyor...', tag: 'AUTH');

      // Google Sign-In akisini tetikle
      GoogleSignInAccount? googleUser;
      
      try {
        DebugLogger.info('Google Sign-In dialog açılıyor...', tag: 'AUTH');
        googleUser = await _googleSignIn.signIn();
      } catch (e) {
        DebugLogger.error(
          'Google Sign-In dialog hatası: $e\n'
          'Hata tipi: ${e.runtimeType}\n'
          'Stack trace: ${StackTrace.current}',
          tag: 'AUTH',
        );
        
        // iOS'ta URL scheme eksikse bu hata oluşur
        if (e.toString().contains('PlatformException') ||
            e.toString().contains('sign_in_failed')) {
          DebugLogger.error(
            'iOS URL Scheme yapılandırması eksik olabilir! '
            'Info.plist dosyasını kontrol edin.',
            tag: 'AUTH',
          );
        }
        
        rethrow;
      }

      if (googleUser == null) {
        DebugLogger.info('Kullanıcı Google girişini iptal etti', tag: 'AUTH');
        return null;
      }

      DebugLogger.info('Google hesabı seçildi: ${googleUser.email}', tag: 'AUTH');

      // Kimlik bilgilerini al
      GoogleSignInAuthentication googleAuth;
      
      try {
        DebugLogger.info('Google authentication token alınıyor...', tag: 'AUTH');
        googleAuth = await googleUser.authentication;
        DebugLogger.info(
          'Token alındı - AccessToken: ${googleAuth.accessToken != null ? "VAR" : "YOK"}, '
          'IdToken: ${googleAuth.idToken != null ? "VAR" : "YOK"}',
          tag: 'AUTH',
        );
      } catch (e) {
        DebugLogger.error(
          'Google authentication hatası: $e',
          tag: 'AUTH',
        );
        rethrow;
      }

      // Firebase credential olustur
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase'e giris yap
      DebugLogger.info('Firebase\'e giriş yapılıyor...', tag: 'AUTH');
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      DebugLogger.success(
        'Firebase giriş başarılı: ${userCredential.user?.email}',
        tag: 'AUTH',
      );

      // Kullanici profilini Firestore'da olustur/guncelle
      final isNewUser = await _createUserProfile(userCredential.user!);

      // Yeni kullanıcıya hoş geldin e-postası gönder
      if (isNewUser) {
        await _emailService.sendWelcomeEmail(userCredential.user!);
      }

      // Google ile giriş yapan kullanıcıya da e-posta doğrulama gönder
      await sendVerificationAfterGoogleSignIn();

      return userCredential;
    } catch (e) {
      DebugLogger.error('Google giris hatasi: $e', tag: 'AUTH');
      rethrow;
    }
  }

  /// Cikis yap
  Future<void> signOut() async {
    try {
      DebugLogger.info('Cikis yapiliyor...', tag: 'AUTH');

      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);

      DebugLogger.success('Basariyla cikis yapildi', tag: 'AUTH');
    } catch (e) {
      DebugLogger.error('Cikis hatasi: $e', tag: 'AUTH');
      rethrow;
    }
  }

  /// Kullanici profilini Firestore'da olustur/guncelle
  /// Returns true if user is new, false if existing
  Future<bool> _createUserProfile(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        // Yeni kullanici profili olustur
        final userProfile = {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'emailPreferences': {
            'welcomeEmail': true,
            'dailySummary': false,
            'goalCompletion': true,
            'verificationReminder': true,
          },
        };

        await userDoc.set(userProfile);
        DebugLogger.success('Yeni kullanici profili olusturuldu', tag: 'AUTH');
        return true; // Yeni kullanıcı
      } else {
        // Mevcut kullanici son giris zamanini guncelle
        await userDoc.update({'lastLoginAt': FieldValue.serverTimestamp()});
        DebugLogger.info('Kullanici son giris zamani guncellendi', tag: 'AUTH');
        return false; // Mevcut kullanıcı
      }
    } catch (e) {
      DebugLogger.error('Kullanici profili olusturma hatasi: $e', tag: 'AUTH');
      rethrow;
    }
  }

  /// Kullanici email adresini guncelle
  Future<void> updateEmail(String newEmail) async {
    try {
      if (!isSignedIn) return;

      await currentUser!.verifyBeforeUpdateEmail(newEmail);
      DebugLogger.success('Email guncelleme dogrulama gonderildi', tag: 'AUTH');
    } catch (e) {
      DebugLogger.error('Email guncelleme hatasi: $e', tag: 'AUTH');
      rethrow;
    }
  }

  /// Kullanici profil bilgilerini guncelle
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      if (!isSignedIn) return;

      await currentUser!.updateDisplayName(displayName);
      if (photoURL != null) {
        await currentUser!.updatePhotoURL(photoURL);
      }

      // Firestore'daki profili de guncelle
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'displayName': displayName,
        'photoURL': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      DebugLogger.success('Kullanici profili guncellendi', tag: 'AUTH');
    } catch (e) {
      DebugLogger.error('Kullanici profili guncelleme hatasi: $e', tag: 'AUTH');
      rethrow;
    }
  }

  /// Email ve şifre ile kayıt ol
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    try {
      DebugLogger.info('Email ile kayıt başlatılıyor: $email', tag: 'AUTH');

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await _createUserProfile(userCredential.user!);

        // Otomatik e-posta doğrulama gönder
        try {
          await userCredential.user!.sendEmailVerification();
          DebugLogger.success('E-posta doğrulama gönderildi', tag: 'AUTH');
        } catch (e) {
          DebugLogger.error(
            'E-posta doğrulama gönderme hatası: $e',
            tag: 'AUTH',
          );
          // E-posta gönderme hatası kayıt işlemini durdurmasın
        }

        DebugLogger.success('Email ile kayıt başarılı', tag: 'AUTH');
        return true;
      }

      return false;
    } catch (e) {
      DebugLogger.error('Email ile kayıt hatası: $e', tag: 'AUTH');
      return false;
    }
  }

  /// Google ile giriş yaptıktan sonra e-posta doğrulama gönder
  Future<void> sendVerificationAfterGoogleSignIn() async {
    try {
      if (currentUser != null) {
        // Google kullanıcıları da dahil herkese e-posta doğrulama gönder
        await currentUser!.sendEmailVerification();
        DebugLogger.success(
          'Google kullanıcısına e-posta doğrulama gönderildi',
          tag: 'AUTH',
        );
      }
    } catch (e) {
      DebugLogger.error(
        'Google kullanıcısına e-posta doğrulama gönderme hatası: $e',
        tag: 'AUTH',
      );
      // Hata olsa da devam et
    }
  }

  /// Email ve şifre ile giriş yap
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      DebugLogger.info('Email ile giriş başlatılıyor: $email', tag: 'AUTH');

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        final isNewUser = await _createUserProfile(userCredential.user!);
        
        // Yeni kullanıcıya hoş geldin e-postası gönder (nadiren olur ama olabilir)
        if (isNewUser) {
          await _emailService.sendWelcomeEmail(userCredential.user!);
        }
        
        DebugLogger.success('Email ile giriş başarılı', tag: 'AUTH');
        return true;
      }

      return false;
    } catch (e) {
      DebugLogger.error('Email ile giriş hatası: $e', tag: 'AUTH');
      return false;
    }
  }

  /// Şifre sıfırlama e-postası gönder
  Future<void> resetPassword(String email) async {
    try {
      DebugLogger.info(
        'Şifre sıfırlama e-postası gönderiliyor: $email',
        tag: 'AUTH',
      );

      await _auth.sendPasswordResetEmail(email: email);

      DebugLogger.success('Şifre sıfırlama e-postası gönderildi', tag: 'AUTH');
    } catch (e) {
      DebugLogger.error('Şifre sıfırlama hatası: $e', tag: 'AUTH');
      rethrow;
    }
  }

  /// Hesap sil
  Future<void> deleteAccount() async {
    try {
      DebugLogger.info('Hesap siliniyor...', tag: 'AUTH');

      final user = currentUser;
      if (user != null) {
        final uid = user.uid;

        // Re-authentication gerekiyorsa yap
        await _reauthenticateIfNeeded(user);

        // Önce Firestore'dan kullanıcı verilerini sil
        await _deleteUserData(uid);

        // Google Sign-In cache'ini güvenli şekilde temizle
        try {
          await _googleSignIn.signOut();
          DebugLogger.info('Google Sign-In signOut başarılı', tag: 'AUTH');
        } catch (e) {
          DebugLogger.warning('Google Sign-In signOut hatası: $e', tag: 'AUTH');
        }

        try {
          await _googleSignIn.disconnect();
          DebugLogger.info('Google Sign-In disconnect başarılı', tag: 'AUTH');
        } catch (e) {
          DebugLogger.warning(
            'Google Sign-In disconnect hatası (devam ediliyor): $e',
            tag: 'AUTH',
          );
          // Disconnect hatası hesap silmeyi durdurmasın
        }

        // Firebase Auth'dan hesabı sil
        await user.delete();

        DebugLogger.success('Hesap başarıyla silindi', tag: 'AUTH');
      }
    } catch (e) {
      DebugLogger.error('Hesap silme hatası: $e', tag: 'AUTH');
      rethrow;
    }
  }

  /// Re-authentication gerekiyorsa yap
  Future<void> _reauthenticateIfNeeded(User user) async {
    try {
      // Google kullanıcısı için re-authentication
      if (user.providerData.any((info) => info.providerId == 'google.com')) {
        DebugLogger.info(
          'Google kullanıcısı için re-authentication yapılıyor',
          tag: 'AUTH',
        );

        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          await user.reauthenticateWithCredential(credential);
          DebugLogger.success('Re-authentication başarılı', tag: 'AUTH');
        }
      }
    } catch (e) {
      DebugLogger.error('Re-authentication hatası: $e', tag: 'AUTH');
      // Re-authentication hatası olsa da devam et
    }
  }

  /// Mevcut kullanıcı ID'si
  String? get currentUserId => currentUser?.uid;

  /// Mevcut kullanıcı e-postası
  String? get currentUserEmail => currentUser?.email;

  /// E-posta doğrulanmış mı?
  bool get isEmailVerified {
    final user = currentUser;
    if (user == null) return false;

    // Google kullanıcıları için özel kontrol
    final isGoogleUser = user.providerData.any(
      (info) => info.providerId == 'google.com',
    );
    if (isGoogleUser) {
      // Google kullanıcıları için manuel doğrulama kontrolü
      return user.emailVerified;
    }

    return user.emailVerified;
  }

  /// E-posta doğrulama gönder
  Future<void> sendEmailVerification() async {
    try {
      if (!isSignedIn) return;

      await currentUser!.sendEmailVerification();
      DebugLogger.success('E-posta doğrulama gönderildi', tag: 'AUTH');
    } catch (e) {
      DebugLogger.error('E-posta doğrulama gönderme hatası: $e', tag: 'AUTH');
      rethrow;
    }
  }

  /// E-posta doğrulama durumunu yenile
  Future<void> reloadUser() async {
    try {
      if (!isSignedIn) return;

      await currentUser!.reload();
      DebugLogger.info('Kullanıcı bilgileri yenilendi', tag: 'AUTH');
    } catch (e) {
      DebugLogger.error('Kullanıcı yenileme hatası: $e', tag: 'AUTH');
      rethrow;
    }
  }

  /// Hesabi sil
  Future<bool> deleteUserAccount() async {
    try {
      if (!isSignedIn) return false;

      final uid = currentUser!.uid;

      // Firestore'daki kullanici verilerini sil
      await _deleteUserData(uid);

      // Google hesabından tamamen çıkış yap ve cache'i temizle
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();

      // Firebase Authentication'dan hesabi sil
      await currentUser!.delete();

      DebugLogger.success(
        'Hesap basariyla silindi ve cache temizlendi',
        tag: 'AUTH',
      );
      return true;
    } catch (e) {
      DebugLogger.error('Hesap silme hatasi: $e', tag: 'AUTH');
      return false;
    }
  }

  /// Google Sign-In cache'ini tamamen temizle
  Future<void> clearGoogleSignInCache() async {
    try {
      await _googleSignIn.signOut();
      DebugLogger.info('Google Sign-In signOut tamamlandı', tag: 'AUTH');
    } catch (e) {
      DebugLogger.warning('Google Sign-In signOut hatası: $e', tag: 'AUTH');
    }

    try {
      await _googleSignIn.disconnect();
      DebugLogger.success(
        'Google Sign-In cache tamamen temizlendi',
        tag: 'AUTH',
      );
    } catch (e) {
      DebugLogger.warning(
        'Google Sign-In disconnect hatası (normal): $e',
        tag: 'AUTH',
      );
      // Disconnect hatası normal olabilir, cache zaten temizlenmiş olabilir
    }
  }

  /// Kullanicinin tum Firestore verilerini sil
  Future<void> _deleteUserData(String uid) async {
    try {
      DebugLogger.info('Kullanıcı verileri siliniyor: $uid', tag: 'AUTH');

      // Ana kullanıcı dokümanını sil
      await _firestore.collection('users').doc(uid).delete();

      // Tüm subcollection'ları sil
      await _deleteSubcollection(uid, 'daily_intake');
      await _deleteSubcollection(uid, 'statistics');
      await _deleteSubcollection(uid, 'notifications');
      await _deleteSubcollection(uid, 'settings');
      await _deleteSubcollection(uid, 'water_history');

      DebugLogger.success('Kullanıcı verileri tamamen silindi', tag: 'AUTH');
    } catch (e) {
      DebugLogger.error('Kullanıcı verilerini silme hatası: $e', tag: 'AUTH');
      rethrow;
    }
  }

  /// Subcollection'ı sil
  Future<void> _deleteSubcollection(String uid, String collectionName) async {
    try {
      final collectionRef = _firestore
          .collection('users')
          .doc(uid)
          .collection(collectionName);

      final snapshots = await collectionRef.get();

      if (snapshots.docs.isNotEmpty) {
        final batch = _firestore.batch();

        for (final doc in snapshots.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
        DebugLogger.info('$collectionName koleksiyonu silindi', tag: 'AUTH');
      }
    } catch (e) {
      DebugLogger.error('$collectionName silme hatası: $e', tag: 'AUTH');
      // Subcollection silme hatası ana işlemi durdurmasın
    }
  }
}
