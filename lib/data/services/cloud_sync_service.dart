import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/water_intake_model.dart';
import '../models/user_model.dart';
import '../models/notification_settings_model.dart';
import '../../core/utils/debug_logger.dart';

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

      DebugLogger.success(
        'Kullanıcı profili Cloud\'a sync edildi',
        tag: 'CLOUD_SYNC',
      );
    } catch (e) {
      DebugLogger.error('Kullanıcı profili sync hatası: $e', tag: 'CLOUD_SYNC');
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
      DebugLogger.error('Kullanıcı profili alma hatası: $e', tag: 'CLOUD_SYNC');
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
          (total, intake) => total + intake.amount,
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

      DebugLogger.success(
        '$dateKey günlük su verisi Cloud\'a sync edildi',
        tag: 'CLOUD_SYNC',
      );
    } catch (e) {
      DebugLogger.error('Günlük su verisi sync hatası: $e', tag: 'CLOUD_SYNC');
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
      DebugLogger.error('Günlük su verisi alma hatası: $e', tag: 'CLOUD_SYNC');
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

      DebugLogger.success(
        '${result.length} günlük su verisi Cloud\'dan alındı',
        tag: 'CLOUD_SYNC',
      );
      return result;
    } catch (e) {
      DebugLogger.error(
        'Tarih aralığı su verisi alma hatası: $e',
        tag: 'CLOUD_SYNC',
      );
      return {};
    }
  }

  // =================== BİLDİRİM AYARLARI ===================

  /// Bildirim ayarlarını Firestore'a kaydet
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    if (!isUserSignedIn) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('settings')
          .doc('notifications')
          .set({
            ...settings.toJson(),
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      DebugLogger.success(
        'Bildirim ayarları Cloud\'a kaydedildi',
        tag: 'CLOUD_SYNC',
      );
    } catch (e) {
      DebugLogger.error(
        'Bildirim ayarları kaydetme hatası: $e',
        tag: 'CLOUD_SYNC',
      );
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
      DebugLogger.error('Bildirim ayarları alma hatası: $e', tag: 'CLOUD_SYNC');
      return null;
    }
  }

  /// Bildirim ayarlarını sil
  Future<void> deleteNotificationSettings() async {
    if (!isUserSignedIn) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('settings')
          .doc('notifications')
          .delete();

      DebugLogger.success(
        'Bildirim ayarları Cloud\'dan silindi',
        tag: 'CLOUD_SYNC',
      );
    } catch (e) {
      DebugLogger.error(
        'Bildirim ayarları silme hatası: $e',
        tag: 'CLOUD_SYNC',
      );
      rethrow;
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

      DebugLogger.success(
        '$monthKey aylık istatistikleri Cloud\'a sync edildi',
        tag: 'CLOUD_SYNC',
      );
    } catch (e) {
      DebugLogger.error('Aylık istatistik sync hatası: $e', tag: 'CLOUD_SYNC');
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

      DebugLogger.success(
        'Tüm zamanlar istatistikleri Cloud\'a sync edildi',
        tag: 'CLOUD_SYNC',
      );
    } catch (e) {
      DebugLogger.error(
        'Tüm zamanlar istatistik sync hatası: $e',
        tag: 'CLOUD_SYNC',
      );
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
      DebugLogger.error('Aylık istatistik alma hatası: $e', tag: 'CLOUD_SYNC');
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
      DebugLogger.error(
        'Tüm zamanlar istatistik alma hatası: $e',
        tag: 'CLOUD_SYNC',
      );
      return null;
    }
  }

  // =================== KULLANICI VERİLERİ (Firebase Generic) ===================

  /// Kullanıcı verilerini Firestore'dan al (Generic)
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        DebugLogger.success(
          'Kullanıcı verisi Cloud\'dan alındı',
          tag: 'CLOUD_SYNC',
        );
        return doc.data();
      }
      return null;
    } catch (e) {
      DebugLogger.error('Kullanıcı verisi alma hatası: $e', tag: 'CLOUD_SYNC');
      rethrow;
    }
  }

  /// Kullanıcı verilerini Firestore'a kaydet (Generic)
  Future<void> saveUserData(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        ...userData,
        'lastSyncAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      DebugLogger.success(
        'Kullanıcı verisi Cloud\'a kaydedildi',
        tag: 'CLOUD_SYNC',
      );
    } catch (e) {
      DebugLogger.error(
        'Kullanıcı verisi kaydetme hatası: $e',
        tag: 'CLOUD_SYNC',
      );
      rethrow;
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
      DebugLogger.success(
        'Tüm kullanıcı verileri Cloud\'dan silindi',
        tag: 'CLOUD_SYNC',
      );
    } catch (e) {
      DebugLogger.error(
        'Kullanıcı verileri silme hatası: $e',
        tag: 'CLOUD_SYNC',
      );
      rethrow;
    }
  }

  /// Çevrimdışı verilerle Cloud verileri senkronize et
  Future<void> performFullSync() async {
    if (!isUserSignedIn) {
      DebugLogger.warning(
        'Kullanıcı giriş yapmamış, sync atlanıyor',
        tag: 'CLOUD_SYNC',
      );
      return;
    }

    try {
      DebugLogger.info(
        'Tam veri senkronizasyonu başlatılıyor...',
        tag: 'CLOUD_SYNC',
      );

      // Bu method'u diğer provider'lardan çağıracağız
      // Her provider kendi verilerini sync edecek

      DebugLogger.success(
        'Tam veri senkronizasyonu tamamlandı',
        tag: 'CLOUD_SYNC',
      );
    } catch (e) {
      DebugLogger.error(
        'Tam veri senkronizasyonu hatası: $e',
        tag: 'CLOUD_SYNC',
      );
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
      DebugLogger.error(
        'Son sync tarihi güncelleme hatası: $e',
        tag: 'CLOUD_SYNC',
      );
    }
  }
}
