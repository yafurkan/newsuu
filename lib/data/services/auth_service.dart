import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

      print('🔥 Firebase giris basarili: ${userCredential.user?.email}');

      // Kullanici profilini Firestore'da olustur/guncelle
      await _createUserProfile(userCredential.user!);

      return userCredential;
    } catch (e) {
      print('❌ Google giris hatasi: $e');
      rethrow;
    }
  }

  /// Cikis yap
  Future<void> signOut() async {
    try {
      print('🔐 Cikis yapiliyor...');

      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);

      print('✅ Basariyla cikis yapildi');
    } catch (e) {
      print('❌ Cikis hatasi: $e');
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
        print('✅ Yeni kullanici profili olusturuldu');
      } else {
        // Mevcut kullanici son giris zamanini guncelle
        await userDoc.update({'lastLoginAt': FieldValue.serverTimestamp()});
        print('🔄 Kullanici son giris zamani guncellendi');
      }
    } catch (e) {
      print('❌ Kullanici profili olusturma hatasi: $e');
      rethrow;
    }
  }

  /// Kullanici email adresini guncelle
  Future<void> updateEmail(String newEmail) async {
    try {
      if (!isSignedIn) return;

      await currentUser!.verifyBeforeUpdateEmail(newEmail);
      print('✅ Email guncelleme dogrulama gonderildi');
    } catch (e) {
      print('❌ Email guncelleme hatasi: $e');
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

      print('✅ Kullanici profili guncellendi');
    } catch (e) {
      print('❌ Kullanici profili guncelleme hatasi: $e');
      rethrow;
    }
  }

  /// Email ve şifre ile kayıt ol
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    try {
      print('📧 Email ile kayıt başlatılıyor: $email');

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await _createUserProfile(userCredential.user!);
        print('✅ Email ile kayıt başarılı');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Email ile kayıt hatası: $e');
      return false;
    }
  }

  /// Email ve şifre ile giriş yap
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('📧 Email ile giriş başlatılıyor: $email');

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await _createUserProfile(userCredential.user!);
        print('✅ Email ile giriş başarılı');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Email ile giriş hatası: $e');
      return false;
    }
  }

  /// Şifre sıfırlama e-postası gönder
  Future<void> resetPassword(String email) async {
    try {
      print('📧 Şifre sıfırlama e-postası gönderiliyor: $email');

      await _auth.sendPasswordResetEmail(email: email);

      print('✅ Şifre sıfırlama e-postası gönderildi');
    } catch (e) {
      print('❌ Şifre sıfırlama hatası: $e');
      rethrow;
    }
  }

  /// Hesap sil
  Future<void> deleteAccount() async {
    try {
      print('🗑️ Hesap siliniyor...');

      final user = currentUser;
      if (user != null) {
        // Firestore'dan kullanıcı verilerini sil
        await _firestore.collection('users').doc(user.uid).delete();

        // Firebase Auth'dan hesabı sil
        await user.delete();

        print('✅ Hesap başarıyla silindi');
      }
    } catch (e) {
      print('❌ Hesap silme hatası: $e');
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

      print('✅ Hesap basariyla silindi');
      return true;
    } catch (e) {
      print('❌ Hesap silme hatasi: $e');
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

      print('🗑️ Kullanici verileri Firestore\'dan silindi');
    } catch (e) {
      print('❌ Kullanici verilerini silme hatasi: $e');
      rethrow;
    }
  }
}
