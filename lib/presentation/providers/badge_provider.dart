import 'package:flutter/material.dart';
import '../../data/models/badge_model.dart';
import '../../data/services/badge_service.dart';
import '../../core/utils/debug_logger.dart';

/// Rozet yönetimi için provider
class BadgeProvider with ChangeNotifier {
  final BadgeService _badgeService = BadgeService();

  List<BadgeModel> _badges = [];
  UserBadgeStats _stats = UserBadgeStats();
  bool _isLoading = false;
  String? _error;
  List<BadgeModel> _recentlyUnlocked = [];
  Map<String, double> _badgeProgress = {};

  // Getters
  List<BadgeModel> get badges => _badges;
  UserBadgeStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BadgeModel> get recentlyUnlocked => _recentlyUnlocked;

  /// Kategoriye göre rozetleri al
  List<BadgeModel> getBadgesByCategory(String category) {
    return _badges.where((badge) => badge.category == category).toList();
  }

  /// Kilidi açılmış rozetleri al
  List<BadgeModel> get unlockedBadges {
    return _badges.where((badge) => badge.isUnlocked).toList();
  }

  /// Kilidi kapalı rozetleri al
  List<BadgeModel> get lockedBadges {
    return _badges.where((badge) => !badge.isUnlocked).toList();
  }

  /// Nadir seviyesine göre rozetleri al
  List<BadgeModel> getBadgesByRarity(int rarity) {
    return _badges.where((badge) => badge.rarity == rarity).toList();
  }

  /// Tüm rozetleri yükle
  Future<void> loadBadges() async {
    try {
      _setLoading(true);
      _error = null;

      _badges = await _badgeService.getAllBadges();
      _stats = await _badgeService.getUserBadgeStats();

      DebugLogger.success('Rozetler yüklendi: ${_badges.length}', tag: 'BADGE_PROVIDER');
    } catch (e) {
      _error = 'Rozetler yüklenirken hata oluştu: $e';
      DebugLogger.error(_error!, tag: 'BADGE_PROVIDER');
    } finally {
      _setLoading(false);
    }
  }

  /// Kullanıcı için varsayılan rozetleri başlat
  Future<void> initializeUserBadges() async {
    try {
      await _badgeService.initializeUserBadges();
      await loadBadges();
      DebugLogger.success('Kullanıcı rozetleri başlatıldı', tag: 'BADGE_PROVIDER');
    } catch (e) {
      _error = 'Rozetler başlatılırken hata oluştu: $e';
      DebugLogger.error(_error!, tag: 'BADGE_PROVIDER');
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
    try {
      final newlyUnlocked = await _badgeService.checkWaterAdditionBadges(
        amount: amount,
        dailyTotal: dailyTotal,
        dailyGoal: dailyGoal,
        consecutiveDays: consecutiveDays,
        buttonUsage: buttonUsage,
      );

      if (newlyUnlocked.isNotEmpty) {
        _recentlyUnlocked.addAll(newlyUnlocked);
        
        // Rozet listesini güncelle
        for (final unlockedBadge in newlyUnlocked) {
          final index = _badges.indexWhere((b) => b.id == unlockedBadge.id);
          if (index != -1) {
            _badges[index] = unlockedBadge;
          }
        }

        // İstatistikleri güncelle
        _stats = await _badgeService.getUserBadgeStats();
        
        notifyListeners();
        
        DebugLogger.success(
          'Yeni rozetler açıldı: ${newlyUnlocked.map((b) => b.name).join(', ')}',
          tag: 'BADGE_PROVIDER',
        );
      }

      return newlyUnlocked;
    } catch (e) {
      DebugLogger.error('Su ekleme rozet kontrolü hatası: $e', tag: 'BADGE_PROVIDER');
      return [];
    }
  }

  /// Son açılan rozetleri temizle
  void clearRecentlyUnlocked() {
    _recentlyUnlocked.clear();
    notifyListeners();
  }

  /// Belirli bir rozeti al
  BadgeModel? getBadgeById(String id) {
    try {
      return _badges.firstWhere((badge) => badge.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Rozet kategorilerini al
  List<String> get categories {
    final categorySet = <String>{};
    for (final badge in _badges) {
      categorySet.add(badge.category);
    }
    return categorySet.toList();
  }

  /// Kategori adını Türkçe'ye çevir
  String getCategoryDisplayName(String category) {
    switch (category) {
      case 'water_drinking':
        return 'Su İçme';
      case 'quick_add':
        return 'Hızlı Ekleme';
      case 'consistency':
        return 'Süreklilik';
      case 'special':
        return 'Özel';
      default:
        return category;
    }
  }

  /// Kategori ikonunu al
  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'water_drinking':
        return Icons.water_drop;
      case 'quick_add':
        return Icons.touch_app;
      case 'consistency':
        return Icons.trending_up;
      case 'special':
        return Icons.star;
      default:
        return Icons.emoji_events;
    }
  }

  /// İlerleme yüzdesini hesapla
  double getProgressPercentage() {
    if (_badges.isEmpty) return 0.0;
    final unlockedCount = _badges.where((badge) => badge.isUnlocked).length;
    return (unlockedCount / _badges.length) * 100;
  }

  /// Kategori bazında ilerleme yüzdesini hesapla
  double getCategoryProgress(String category) {
    final categoryBadges = getBadgesByCategory(category);
    if (categoryBadges.isEmpty) return 0.0;
    
    final unlockedCount = categoryBadges.where((badge) => badge.isUnlocked).length;
    return (unlockedCount / categoryBadges.length) * 100;
  }

  /// En son açılan rozeti al
  BadgeModel? get lastUnlockedBadge {
    final unlockedBadges = _badges.where((badge) => badge.isUnlocked).toList();
    if (unlockedBadges.isEmpty) return null;
    
    unlockedBadges.sort((a, b) => 
        (b.unlockedAt ?? DateTime(0)).compareTo(a.unlockedAt ?? DateTime(0)));
    
    return unlockedBadges.first;
  }

  /// Bir sonraki hedef rozeti al
  BadgeModel? getNextTargetBadge() {
    final lockedBadges = _badges.where((badge) => !badge.isUnlocked).toList();
    if (lockedBadges.isEmpty) return null;
    
    // En düşük gereksinimi olan rozeti bul
    lockedBadges.sort((a, b) => a.requiredValue.compareTo(b.requiredValue));
    
    return lockedBadges.first;
  }

  /// Rozet başarı mesajı oluştur
  String getBadgeAchievementMessage(BadgeModel badge) {
    final rarityEmoji = _getRarityEmoji(badge.rarity);
    return '$rarityEmoji ${badge.name} rozetini kazandınız!\n\n${badge.description}\n\n💡 ${badge.funFact}';
  }

  /// Nadir seviye emoji'si al
  String _getRarityEmoji(int rarity) {
    switch (rarity) {
      case 1:
        return '🥉'; // Yaygın - Bronz
      case 2:
        return '🥈'; // Nadir - Gümüş
      case 3:
        return '🥇'; // Efsane - Altın
      case 4:
        return '💎'; // Mitik - Elmas
      default:
        return '🏆';
    }
  }

  /// Loading durumunu ayarla
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Hata durumunu temizle
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Provider'ı sıfırla
  void reset() {
    _badges.clear();
    _stats = UserBadgeStats();
    _recentlyUnlocked.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// Rozet stream'ini dinle
  void startListening() {
    _badgeService.getBadgesStream().listen(
      (badges) {
        _badges = badges;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Rozet stream hatası: $error';
        DebugLogger.error(_error!, tag: 'BADGE_PROVIDER');
        notifyListeners();
      },
    );

    _badgeService.getUserBadgeStatsStream().listen(
      (stats) {
        _stats = stats;
        notifyListeners();
      },
      onError: (error) {
        DebugLogger.error('Rozet istatistik stream hatası: $error', tag: 'BADGE_PROVIDER');
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}