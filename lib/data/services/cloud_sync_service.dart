import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/water_intake_model.dart';
import '../models/user_model.dart';
import '../models/notification_settings_model.dart';

/// Firebase Firestore ile veri senkronizasyonu servisi
class CloudSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Mevcut kullanıcının ID'si
  String? get _userId => _auth.currentUser?.uid;

  /// Kullanıcı giriş yapmış mı kontrol et
  bool get isUserSignedIn => _auth.currentUser != null;

  // =================== KULLANICI PROFİLİ ===================

  /// Kullanıcı profilini Firestore'a kaydet
  Future<void> syncUserProfile(UserModel user) async {
    if (!isUserSignedIn) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('profile')
          .doc('info')
          .set({
            ...user.toJson(),
            'lastSyncAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      print('✅ Kullanıcı profili Cloud\'a sync edildi');
    } catch (e) {
      print('❌ Kullanıcı profili sync hatası: $e');
      rethrow;
    }
  }

  /// Kullanıcı profilini Firestore'dan al
  Future<UserModel?> getUserProfile() async {
    if (!isUserSignedIn) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('profile')
          .doc('info')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('❌ Kullanıcı profili alma hatası: $e');
      return null;
    }
  }

  // =================== SU TÜKETİM VERİLERİ ===================

  /// Günlük su tüketim verisini Firestore'a kaydet
  Future<void> syncDailyWaterIntake(
    DateTime date,
    List<WaterIntakeModel> intakes,
  ) async {
    if (!isUserSignedIn) return;

    try {
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final data = {
        'date': dateKey,
        'intakes': intakes.map((intake) => intake.toJson()).toList(),
        'totalAmount': intakes.fold<double>(
          0,
          (sum, intake) => sum + intake.amount,
        ),
        'intakeCount': intakes.length,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('daily_intake')
          .doc(dateKey)
          .set(data, SetOptions(merge: true));

      print('✅ $dateKey günlük su verisi Cloud\'a sync edildi');
    } catch (e) {
      print('❌ Günlük su verisi sync hatası: $e');
      rethrow;
    }
  }

  /// Belirli bir günün su tüketim verisini al
  Future<List<WaterIntakeModel>> getDailyWaterIntake(DateTime date) async {
    if (!isUserSignedIn) return [];

    try {
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('daily_intake')
          .doc(dateKey)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final intakesData = data['intakes'] as List<dynamic>? ?? [];

        return intakesData
            .map(
              (intake) =>
                  WaterIntakeModel.fromJson(Map<String, dynamic>.from(intake)),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Günlük su verisi alma hatası: $e');
      return [];
    }
  }

  /// Belirli tarih aralığındaki tüm su tüketim verilerini al
  Future<Map<String, List<WaterIntakeModel>>> getWaterIntakeRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (!isUserSignedIn) return {};

    try {
      final startKey =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endKey =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('daily_intake')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startKey)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endKey)
          .orderBy(FieldPath.documentId)
          .get();

      final result = <String, List<WaterIntakeModel>>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final intakesData = data['intakes'] as List<dynamic>? ?? [];

        final intakes = intakesData
            .map(
              (intake) =>
                  WaterIntakeModel.fromJson(Map<String, dynamic>.from(intake)),
            )
            .toList();

        result[doc.id] = intakes;
      }

      print('✅ ${result.length} günlük su verisi Cloud\'dan alındı');
      return result;
    } catch (e) {
      print('❌ Tarih aralığı su verisi alma hatası: $e');
      return {};
    }
  }

  // =================== BİLDİRİM AYARLARI ===================

  /// Bildirim ayarlarını Firestore'a kaydet
  Future<void> syncNotificationSettings(NotificationSettings settings) async {
    if (!isUserSignedIn) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('settings')
          .doc('notifications')
          .set({
            ...settings.toJson(),
            'lastSyncAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      print('✅ Bildirim ayarları Cloud\'a sync edildi');
    } catch (e) {
      print('❌ Bildirim ayarları sync hatası: $e');
      rethrow;
    }
  }

  /// Bildirim ayarlarını Firestore'dan al
  Future<NotificationSettings?> getNotificationSettings() async {
    if (!isUserSignedIn) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('settings')
          .doc('notifications')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return NotificationSettings.fromJson(data);
      }
      return null;
    } catch (e) {
      print('❌ Bildirim ayarları alma hatası: $e');
      return null;
    }
  }

  // =================== İSTATİSTİKLER ===================

  /// Aylık istatistikleri Firestore'a kaydet
  Future<void> syncMonthlyStats(
    int year,
    int month,
    Map<String, dynamic> stats,
  ) async {
    if (!isUserSignedIn) return;

    try {
      final monthKey = '$year-${month.toString().padLeft(2, '0')}';

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('statistics')
          .doc('monthly')
          .collection('data')
          .doc(monthKey)
          .set({
            ...stats,
            'year': year,
            'month': month,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      print('✅ $monthKey aylık istatistikleri Cloud\'a sync edildi');
    } catch (e) {
      print('❌ Aylık istatistik sync hatası: $e');
      rethrow;
    }
  }

  /// Tüm zamanların istatistiklerini kaydet
  Future<void> syncAllTimeStats(Map<String, dynamic> stats) async {
    if (!isUserSignedIn) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('statistics')
          .doc('all_time')
          .set({
            ...stats,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      print('✅ Tüm zamanlar istatistikleri Cloud\'a sync edildi');
    } catch (e) {
      print('❌ Tüm zamanlar istatistik sync hatası: $e');
      rethrow;
    }
  }

  /// Aylık istatistikleri al
  Future<Map<String, dynamic>?> getMonthlyStats(int year, int month) async {
    if (!isUserSignedIn) return null;

    try {
      final monthKey = '$year-${month.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('statistics')
          .doc('monthly')
          .collection('data')
          .doc(monthKey)
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('❌ Aylık istatistik alma hatası: $e');
      return null;
    }
  }

  /// Tüm zamanların istatistiklerini al
  Future<Map<String, dynamic>?> getAllTimeStats() async {
    if (!isUserSignedIn) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('statistics')
          .doc('all_time')
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('❌ Tüm zamanlar istatistik alma hatası: $e');
      return null;
    }
  }

  // =================== GENEL İŞLEMLER ===================

  /// Kullanıcının tüm verilerini sil (hesap silme için)
  Future<void> deleteAllUserData() async {
    if (!isUserSignedIn) return;

    try {
      final batch = _firestore.batch();

      // Ana kullanıcı koleksiyonunu sil
      final userRef = _firestore.collection('users').doc(_userId);
      batch.delete(userRef);

      // Alt koleksiyonları sil
      final collections = ['profile', 'daily_intake', 'settings', 'statistics'];

      for (final collectionName in collections) {
        final snapshot = await userRef.collection(collectionName).get();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
      }

      await batch.commit();
      print('🗑️ Tüm kullanıcı verileri Cloud\'dan silindi');
    } catch (e) {
      print('❌ Kullanıcı verileri silme hatası: $e');
      rethrow;
    }
  }

  /// Çevrimdışı verilerle Cloud verileri senkronize et
  Future<void> performFullSync() async {
    if (!isUserSignedIn) {
      print('⚠️ Kullanıcı giriş yapmamış, sync atlanıyor');
      return;
    }

    try {
      print('🔄 Tam veri senkronizasyonu başlatılıyor...');

      // Bu method'u diğer provider'lardan çağıracağız
      // Her provider kendi verilerini sync edecek

      print('✅ Tam veri senkronizasyonu tamamlandı');
    } catch (e) {
      print('❌ Tam veri senkronizasyonu hatası: $e');
      rethrow;
    }
  }

  /// Kullanıcının son sync tarihini güncelle
  Future<void> updateLastSyncTime() async {
    if (!isUserSignedIn) return;

    try {
      await _firestore.collection('users').doc(_userId).update({
        'lastSyncAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Son sync tarihi güncelleme hatası: $e');
    }
  }
}
