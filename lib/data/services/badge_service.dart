import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/badge_model.dart';
import '../../core/utils/debug_logger.dart';

/// Rozet yönetim servisi
class BadgeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Mevcut kullanıcı ID'si
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Tüm rozetleri al
  Future<List<BadgeModel>> getAllBadges() async {
    try {
      if (_currentUserId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('badges')
          .orderBy('category')
          .orderBy('requiredValue')
          .get();

      return snapshot.docs
          .map((doc) => BadgeModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      DebugLogger.error('Rozetleri alma hatası: $e', tag: 'BADGE');
      return [];
    }
  }

  /// Kategoriye göre rozetleri al
  Future<List<BadgeModel>> getBadgesByCategory(String category) async {
    try {
      if (_currentUserId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('badges')
          .where('category', isEqualTo: category)
          .orderBy('requiredValue')
          .get();

      return snapshot.docs
          .map((doc) => BadgeModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      DebugLogger.error('Kategori rozetleri alma hatası: $e', tag: 'BADGE');
      return [];
    }
  }

  /// Kilidi açılmış rozetleri al
  Future<List<BadgeModel>> getUnlockedBadges() async {
    try {
      if (_currentUserId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('badges')
          .where('isUnlocked', isEqualTo: true)
          .orderBy('unlockedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BadgeModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      DebugLogger.error('Kilidi açık rozetleri alma hatası: $e', tag: 'BADGE');
      return [];
    }
  }

  /// Kullanıcı rozet istatistiklerini al
  Future<UserBadgeStats> getUserBadgeStats() async {
    try {
      if (_currentUserId == null) return UserBadgeStats();

      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('badges')
          .get();

      final badges = snapshot.docs
          .map((doc) => BadgeModel.fromJson(doc.data()))
          .toList();

      final unlockedBadges = badges.where((badge) => badge.isUnlocked).toList();

      return UserBadgeStats(
        totalBadges: badges.length,
        unlockedBadges: unlockedBadges.length,
        commonBadges: unlockedBadges.where((b) => b.rarity == 1).length,
        rareBadges: unlockedBadges.where((b) => b.rarity == 2).length,
        legendaryBadges: unlockedBadges.where((b) => b.rarity == 3).length,
        mythicBadges: unlockedBadges.where((b) => b.rarity == 4).length,
        lastUnlockedAt: unlockedBadges.isNotEmpty
            ? unlockedBadges
                  .reduce(
                    (a, b) =>
                        (a.unlockedAt?.isAfter(b.unlockedAt ?? DateTime(0)) ??
                            false)
                        ? a
                        : b,
                  )
                  .unlockedAt
            : null,
        lastUnlockedBadgeId: unlockedBadges.isNotEmpty
            ? unlockedBadges
                  .reduce(
                    (a, b) =>
                        (a.unlockedAt?.isAfter(b.unlockedAt ?? DateTime(0)) ??
                            false)
                        ? a
                        : b,
                  )
                  .id
            : null,
      );
    } catch (e) {
      DebugLogger.error(
        'Kullanıcı rozet istatistikleri alma hatası: $e',
        tag: 'BADGE',
      );
      return UserBadgeStats();
    }
  }

  /// Rozet kilidini aç
  Future<bool> unlockBadge(String badgeId) async {
    try {
      if (_currentUserId == null) return false;

      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('badges')
          .doc(badgeId)
          .update({
            'isUnlocked': true,
            'unlockedAt': FieldValue.serverTimestamp(),
          });

      DebugLogger.success('Rozet kilidi açıldı: $badgeId', tag: 'BADGE');
      return true;
    } catch (e) {
      DebugLogger.error('Rozet kilidi açma hatası: $e', tag: 'BADGE');
      return false;
    }
  }

  /// Su ekleme işlemini kontrol et ve rozetleri değerlendir
  Future<List<BadgeModel>> checkWaterAdditionBadges({
    required int amount,
    required int dailyTotal,
    required int dailyGoal,
    required int consecutiveDays,
    required Map<String, int> buttonUsage,
  }) async {
    final newlyUnlockedBadges = <BadgeModel>[];

    try {
      if (_currentUserId == null) return newlyUnlockedBadges;

      final badges = await getAllBadges();

      for (final badge in badges) {
        if (badge.isUnlocked) continue;

        bool shouldUnlock = false;

        switch (badge.requiredAction) {
          case 'first_water_add':
            shouldUnlock = amount > 0;
            break;
          case 'daily_goal_complete':
            shouldUnlock = dailyTotal >= dailyGoal;
            break;
          case 'daily_amount_3000':
            shouldUnlock = dailyTotal >= 3000;
            break;
          case 'daily_amount_5000':
            shouldUnlock = dailyTotal >= 5000;
            break;
          case 'consecutive_days':
            shouldUnlock = consecutiveDays >= badge.requiredValue;
            break;
          case 'button_250ml_first':
            shouldUnlock =
                buttonUsage['250'] != null && buttonUsage['250']! >= 1;
            break;
          case 'button_500ml_10_times':
            shouldUnlock =
                buttonUsage['500'] != null && buttonUsage['500']! >= 10;
            break;
          case 'button_750ml_5_times':
            shouldUnlock =
                buttonUsage['750'] != null && buttonUsage['750']! >= 5;
            break;
          case 'button_1000ml_first':
            shouldUnlock =
                buttonUsage['1000'] != null && buttonUsage['1000']! >= 1;
            break;
          case 'all_buttons_used':
            shouldUnlock = buttonUsage.values.every((usage) => usage > 0);
            break;
        }

        if (shouldUnlock) {
          final success = await unlockBadge(badge.id);
          if (success) {
            newlyUnlockedBadges.add(badge.unlock());
          }
        }
      }
    } catch (e) {
      DebugLogger.error('Su ekleme rozet kontrolü hatası: $e', tag: 'BADGE');
    }

    return newlyUnlockedBadges;
  }

  /// Kullanıcı için varsayılan rozetleri oluştur
  Future<void> initializeUserBadges() async {
    try {
      if (_currentUserId == null) return;

      final userBadgesRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('badges');

      // Mevcut rozetleri kontrol et
      final existingBadges = await userBadgesRef.get();
      if (existingBadges.docs.isNotEmpty) {
        DebugLogger.info('Kullanıcı rozetleri zaten mevcut', tag: 'BADGE');
        return;
      }

      final defaultBadges = _getDefaultBadges();
      final batch = _firestore.batch();

      for (final badge in defaultBadges) {
        final docRef = userBadgesRef.doc(badge.id);
        batch.set(docRef, badge.toJson());
      }

      await batch.commit();
      DebugLogger.success('Varsayılan rozetler oluşturuldu', tag: 'BADGE');
    } catch (e) {
      DebugLogger.error('Varsayılan rozet oluşturma hatası: $e', tag: 'BADGE');
    }
  }

  /// Varsayılan rozetleri tanımla
  List<BadgeModel> _getDefaultBadges() {
    return [
      // Su İçme Rozetleri
      BadgeModel(
        id: 'first_drop',
        name: 'İlk Damla',
        description: 'İlk su kaydınızı yaptınız!',
        category: 'water_drinking',
        iconPath: 'assets/badges/first_drop.png',
        funFact: 'İnsan vücudunun %60\'ı sudan oluşur. İlk adımınızı attınız!',
        requiredValue: 1,
        requiredAction: 'first_water_add',
        rarity: 1,
        colors: ['#4FC3F7', '#29B6F6'],
      ),
      BadgeModel(
        id: 'water_lover',
        name: 'Su Sever',
        description: 'Günlük hedefinizi tamamladınız!',
        category: 'water_drinking',
        iconPath: 'assets/badges/water_lover.png',
        funFact:
            'Günde 8 bardak su içmek genel bir tavsiyedir, ama kişisel ihtiyaçlar değişir.',
        requiredValue: 1,
        requiredAction: 'daily_goal_complete',
        rarity: 1,
        colors: ['#7ED321', '#66BB6A'],
      ),
      BadgeModel(
        id: 'water_monster',
        name: 'Su Canavarı',
        description: 'Günde 3 litre su içtiniz!',
        category: 'water_drinking',
        iconPath: 'assets/badges/water_monster.png',
        funFact:
            'Dünyanın en çok su içen hayvanı fil, günde 300 litreye kadar su içebilir!',
        requiredValue: 3000,
        requiredAction: 'daily_amount_3000',
        rarity: 2,
        colors: ['#50E3C2', '#4FC3F7'],
      ),
      BadgeModel(
        id: 'ocean_king',
        name: 'Okyanus Kralı',
        description: 'Günde 5 litre su içtiniz!',
        category: 'water_drinking',
        iconPath: 'assets/badges/ocean_king.png',
        funFact:
            'Mavi balina, dünyanın en büyük hayvanı olarak günde 16 ton su filtreler!',
        requiredValue: 5000,
        requiredAction: 'daily_amount_5000',
        rarity: 3,
        colors: ['#F5A623', '#FF8C00'],
      ),

      // Hızlı Ekleme Rozetleri
      BadgeModel(
        id: 'quick_start',
        name: 'Hızlı Başlangıç',
        description: '250ml butonunu ilk kez kullandınız!',
        category: 'quick_add',
        iconPath: 'assets/badges/quick_start.png',
        funFact: '250ml, yaklaşık bir su bardağına eşittir.',
        requiredValue: 1,
        requiredAction: 'button_250ml_first',
        rarity: 1,
        colors: ['#4A90E2', '#7BB3F0'],
      ),
      BadgeModel(
        id: 'classic_choice',
        name: 'Klasik Seçim',
        description: '500ml butonunu 10 kez kullandınız!',
        category: 'quick_add',
        iconPath: 'assets/badges/classic_choice.png',
        funFact: '500ml, standart bir su şişesinin boyutudur.',
        requiredValue: 10,
        requiredAction: 'button_500ml_10_times',
        rarity: 2,
        colors: ['#7ED321', '#9FE654'],
      ),
      BadgeModel(
        id: 'big_gulp',
        name: 'Büyük Yudum',
        description: '750ml butonunu 5 kez kullandınız!',
        category: 'quick_add',
        iconPath: 'assets/badges/big_gulp.png',
        funFact: '750ml, büyük bir su şişesinin kapasitesidir.',
        requiredValue: 5,
        requiredAction: 'button_750ml_5_times',
        rarity: 2,
        colors: ['#50E3C2', '#7EEADB'],
      ),
      BadgeModel(
        id: 'mega_drinker',
        name: 'Mega İçici',
        description: '1000ml butonunu ilk kez kullandınız!',
        category: 'quick_add',
        iconPath: 'assets/badges/mega_drinker.png',
        funFact: '1 litre su, vücut ağırlığının %1.5\'ine eşittir (70kg için).',
        requiredValue: 1,
        requiredAction: 'button_1000ml_first',
        rarity: 2,
        colors: ['#FF6B6B', '#FF8E8E'],
      ),
      BadgeModel(
        id: 'button_master',
        name: 'Buton Ustası',
        description: 'Tüm hızlı ekleme butonlarını kullandınız!',
        category: 'quick_add',
        iconPath: 'assets/badges/button_master.png',
        funFact: 'Çeşitlilik, sağlıklı alışkanlıkların anahtarıdır!',
        requiredValue: 1,
        requiredAction: 'all_buttons_used',
        rarity: 3,
        colors: ['#9B59B6', '#BB6BD9'],
      ),

      // Süreklilik Rozetleri
      BadgeModel(
        id: 'first_step',
        name: 'İlk Adım',
        description: '3 gün üst üste su ekleme yaptınız!',
        category: 'consistency',
        iconPath: 'assets/badges/first_step.png',
        funFact: 'Bir alışkanlığın oluşması ortalama 21 gün sürer.',
        requiredValue: 3,
        requiredAction: 'consecutive_days',
        rarity: 1,
        colors: ['#4A90E2', '#50E3C2'],
      ),
      BadgeModel(
        id: 'determined',
        name: 'Kararlı',
        description: '7 gün üst üste su ekleme yaptınız!',
        category: 'consistency',
        iconPath: 'assets/badges/determined.png',
        funFact:
            'Bir hafta boyunca düzenli su içmek, vücut fonksiyonlarını iyileştirir.',
        requiredValue: 7,
        requiredAction: 'consecutive_days',
        rarity: 2,
        colors: ['#7ED321', '#66BB6A'],
      ),
      BadgeModel(
        id: 'persistent',
        name: 'Azimli',
        description: '15 gün üst üste su ekleme yaptınız!',
        category: 'consistency',
        iconPath: 'assets/badges/persistent.png',
        funFact:
            'İki hafta düzenli su tüketimi, cilt sağlığını belirgin şekilde iyileştirir.',
        requiredValue: 15,
        requiredAction: 'consecutive_days',
        rarity: 2,
        colors: ['#F39C12', '#E67E22'],
      ),
      BadgeModel(
        id: 'legendary',
        name: 'Efsane',
        description: '30 gün üst üste su ekleme yaptınız!',
        category: 'consistency',
        iconPath: 'assets/badges/legendary.png',
        funFact:
            'Bir ay boyunca düzenli su içmek, kalıcı bir yaşam tarzı değişikliğidir!',
        requiredValue: 30,
        requiredAction: 'consecutive_days',
        rarity: 3,
        colors: ['#F5A623', '#FF8C00'],
      ),
      BadgeModel(
        id: 'water_god',
        name: 'Su Tanrısı',
        description: '100 gün üst üste su ekleme yaptınız!',
        category: 'consistency',
        iconPath: 'assets/badges/water_god.png',
        funFact:
            'Poseidon, Yunan mitolojisinde denizlerin ve suların tanrısıdır. Siz de artık bir su tanrısısınız!',
        requiredValue: 100,
        requiredAction: 'consecutive_days',
        rarity: 4,
        colors: ['#D0021B', '#FF4757'],
      ),

      // Özel Günler Rozetleri
      BadgeModel(
        id: 'welcome',
        name: 'Hoş Geldin',
        description: 'Su Takip ailesine katıldınız!',
        category: 'special',
        iconPath: 'assets/badges/welcome.png',
        funFact: 'Sağlıklı yaşama attığınız ilk adım için tebrikler!',
        requiredValue: 1,
        requiredAction: 'first_registration',
        rarity: 1,
        colors: ['#4A90E2', '#7BB3F0'],
        isUnlocked: true, // İlk kayıtta otomatik açılır
      ),
    ];
  }

  /// Rozet stream'i - gerçek zamanlı güncellemeler için
  Stream<List<BadgeModel>> getBadgesStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('badges')
        .orderBy('category')
        .orderBy('requiredValue')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BadgeModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Kullanıcı rozet istatistikleri stream'i
  Stream<UserBadgeStats> getUserBadgeStatsStream() {
    if (_currentUserId == null) {
      return Stream.value(UserBadgeStats());
    }

    return getBadgesStream().map((badges) {
      final unlockedBadges = badges.where((badge) => badge.isUnlocked).toList();

      return UserBadgeStats(
        totalBadges: badges.length,
        unlockedBadges: unlockedBadges.length,
        commonBadges: unlockedBadges.where((b) => b.rarity == 1).length,
        rareBadges: unlockedBadges.where((b) => b.rarity == 2).length,
        legendaryBadges: unlockedBadges.where((b) => b.rarity == 3).length,
        mythicBadges: unlockedBadges.where((b) => b.rarity == 4).length,
        lastUnlockedAt: unlockedBadges.isNotEmpty
            ? unlockedBadges
                  .reduce(
                    (a, b) =>
                        (a.unlockedAt?.isAfter(b.unlockedAt ?? DateTime(0)) ??
                            false)
                        ? a
                        : b,
                  )
                  .unlockedAt
            : null,
        lastUnlockedBadgeId: unlockedBadges.isNotEmpty
            ? unlockedBadges
                  .reduce(
                    (a, b) =>
                        (a.unlockedAt?.isAfter(b.unlockedAt ?? DateTime(0)) ??
                            false)
                        ? a
                        : b,
                  )
                  .id
            : null,
      );
    });
  }
}
