import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/debug_logger.dart';

/// Firebase Authentication ve Google Sign-In servisi
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mevcut kullaniciyi al
  User? get currentUser => _auth.currentUser;

  /// Authentication durumu stream'i
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Kullanici giris yapmis mi?
  bool get isSignedIn => currentUser != null;

  /// Google ile giris yap
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Google ile giris baslatiliyor...

      // Google Sign-In akisini tetikle
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Kullanici Google girisini iptal etti
        return null;
      }

      // Google hesabi secildi: ${googleUser.email}

      // Kimlik bilgilerini al
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase credential olustur
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase'e giris yap
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      DebugLogger.success(
        'Firebase giris basarili: ${userCredential.user?.email}',
        tag: 'AUTH',
      );

      // Kullanici profilini Firestore'da olustur/guncelle
      await _createUserProfile(userCredential.user!);

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
  Future<void> _createUserProfile(User user) async {
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
        };

        await userDoc.set(userProfile);
        DebugLogger.success('Yeni kullanici profili olusturuldu', tag: 'AUTH');
      } else {
        // Mevcut kullanici son giris zamanini guncelle
        await userDoc.update({'lastLoginAt': FieldValue.serverTimestamp()});
        DebugLogger.info('Kullanici son giris zamani guncellendi', tag: 'AUTH');
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
        DebugLogger.success('Email ile kayıt başarılı', tag: 'AUTH');
        return true;
      }

      return false;
    } catch (e) {
      DebugLogger.error('Email ile kayıt hatası: $e', tag: 'AUTH');
      return false;
    }
  }

  /// Email ve şifre ile giriş yap
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      DebugLogger.info('Email ile giriş başlatılıyor: $email', tag: 'AUTH');

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await _createUserProfile(userCredential.user!);
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
        // Firestore'dan kullanıcı verilerini sil
        await _firestore.collection('users').doc(user.uid).delete();

        // Firebase Auth'dan hesabı sil
        await user.delete();

        DebugLogger.success('Hesap başarıyla silindi', tag: 'AUTH');
      }
    } catch (e) {
      DebugLogger.error('Hesap silme hatası: $e', tag: 'AUTH');
      rethrow;
    }
  }

  /// Mevcut kullanıcı ID'si
  String? get currentUserId => currentUser?.uid;

  /// Mevcut kullanıcı e-postası
  String? get currentUserEmail => currentUser?.email;

  /// Hesabi sil
  Future<bool> deleteUserAccount() async {
    try {
      if (!isSignedIn) return false;

      final uid = currentUser!.uid;

      // Firestore'daki kullanici verilerini sil
      await _deleteUserData(uid);

      // Google hesabindan cikis yap
      await _googleSignIn.signOut();

      // Firebase Authentication'dan hesabi sil
      await currentUser!.delete();

      DebugLogger.success('Hesap basariyla silindi', tag: 'AUTH');
      return true;
    } catch (e) {
      DebugLogger.error('Hesap silme hatasi: $e', tag: 'AUTH');
      return false;
    }
  }

  /// Kullanicinin tum Firestore verilerini sil
  Future<void> _deleteUserData(String uid) async {
    try {
      final batch = _firestore.batch();

      // Ana kullanici dokumanini sil
      batch.delete(_firestore.collection('users').doc(uid));

      // Su takip verilerini sil (subcollection'lar)
      final dailyIntakeRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('daily_intake');

      final dailySnapshots = await dailyIntakeRef.get();
      for (final doc in dailySnapshots.docs) {
        batch.delete(doc.reference);
      }

      // Statistics verilerini sil
      final statsRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('statistics');

      final statsSnapshots = await statsRef.get();
      for (final doc in statsSnapshots.docs) {
        batch.delete(doc.reference);
      }

      // Batch islemini commit et
      await batch.commit();

      DebugLogger.info(
        'Kullanici verileri Firestore\'dan silindi',
        tag: 'AUTH',
      );
    } catch (e) {
      DebugLogger.error('Kullanici verilerini silme hatasi: $e', tag: 'AUTH');
      rethrow;
    }
  }
}
