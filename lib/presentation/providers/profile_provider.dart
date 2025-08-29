import 'package:flutter/material.dart';
import '../../domain/services/local_avatar_service.dart';
import '../../domain/services/hydration_goal_service.dart';
import 'user_provider.dart';
import 'notification_provider.dart';
import 'badge_provider.dart';
import '../../core/utils/debug_logger.dart';

/// Profil ekranı için özel provider
/// Mevcut provider'ları koordine eder ve profil UI için gerekli verileri sağlar
class ProfileProvider extends ChangeNotifier {
  final LocalAvatarService _avatarService;
  final UserProvider _userProvider;
  final NotificationProvider _notificationProvider;
  final BadgeProvider _badgeProvider;

  String? _avatarPath;
  bool _isLoadingAvatar = false;
  String? _errorMessage;

  ProfileProvider({
    required LocalAvatarService avatarService,
    required UserProvider userProvider,
    required NotificationProvider notificationProvider,
    required BadgeProvider badgeProvider,
  })  : _avatarService = avatarService,
        _userProvider = userProvider,
        _notificationProvider = notificationProvider,
        _badgeProvider = badgeProvider {
    _loadAvatar();
    
    // Diğer provider'ları dinle
    _userProvider.addListener(_onUserDataChanged);
    _notificationProvider.addListener(_onNotificationSettingsChanged);
    _badgeProvider.addListener(_onBadgeDataChanged);
  }

  @override
  void dispose() {
    _userProvider.removeListener(_onUserDataChanged);
    _notificationProvider.removeListener(_onNotificationSettingsChanged);
    _badgeProvider.removeListener(_onBadgeDataChanged);
    super.dispose();
  }

  // Getters
  String? get avatarPath => _avatarPath;
  bool get isLoadingAvatar => _isLoadingAvatar;
  String? get errorMessage => _errorMessage;

  /// Kullanıcı adını al (UserProvider'dan)
  String get displayName {
    final fullName = _userProvider.fullName.trim();
    return fullName.isNotEmpty ? fullName : 'Kullanıcı';
  }

  /// Günlük su hedefini al (UserProvider'dan, formatlanmış)
  String get dailyGoalFormatted {
    final goalMl = _userProvider.dailyWaterGoal;
    if (goalMl >= 1000) {
      final goalL = goalMl / 1000;
      return '${goalL.toStringAsFixed(goalL.truncateToDouble() == goalL ? 0 : 1)} L';
    }
    return '${goalMl.toInt()} ml';
  }

  /// Günlük su hedefini ml olarak al
  double get dailyGoalMl => _userProvider.dailyWaterGoal;

  /// Bildirim durumunu al (NotificationProvider'dan)
  bool get notificationsEnabled => _notificationProvider.isEnabled;

  /// Bildirim durumu metni
  String get notificationStatusText => notificationsEnabled ? 'Açık' : 'Kapalı';

  /// Kazanılan rozet sayısını al (BadgeProvider'dan)
  int get earnedBadgesCount => _badgeProvider.stats.unlockedBadges;

  /// Toplam rozet sayısını al (BadgeProvider'dan)
  int get totalBadgesCount => _badgeProvider.stats.totalBadges;

  /// Rozet durumu metni
  String get badgeStatusText => '$earnedBadgesCount / $totalBadgesCount';

  /// Avatar'ı yükle
  Future<void> _loadAvatar() async {
    try {
      _setLoadingAvatar(true);
      _clearError();

      _avatarPath = await _avatarService.getAvatar();
      
      DebugLogger.info(
        _avatarPath != null 
          ? '✅ Avatar yüklendi: $_avatarPath'
          : 'ℹ️ Avatar bulunamadı',
        tag: 'PROFILE_PROVIDER',
      );
    } catch (e) {
      _setError('Avatar yükleme hatası: $e');
      DebugLogger.error(
        'Avatar yükleme hatası: $e',
        tag: 'PROFILE_PROVIDER',
      );
    } finally {
      _setLoadingAvatar(false);
    }
  }

  /// Avatar değiştir (galeri'den seç)
  Future<bool> changeAvatar() async {
    try {
      _setLoadingAvatar(true);
      _clearError();

      final newAvatarPath = await _avatarService.pickAndSaveAvatar();
      
      if (newAvatarPath != null) {
        _avatarPath = newAvatarPath;
        
        DebugLogger.success(
          'Avatar başarıyla değiştirildi: $newAvatarPath',
          tag: 'PROFILE_PROVIDER',
        );
        
        notifyListeners();
        return true;
      }
      
      return false; // İptal edildi
    } catch (e) {
      _setError('Avatar değiştirme hatası: $e');
      DebugLogger.error(
        'Avatar değiştirme hatası: $e',
        tag: 'PROFILE_PROVIDER',
      );
      return false;
    } finally {
      _setLoadingAvatar(false);
    }
  }

  /// Avatar'ı sil
  Future<bool> deleteAvatar() async {
    try {
      _setLoadingAvatar(true);
      _clearError();

      final deleted = await _avatarService.deleteAvatar();
      
      if (deleted) {
        _avatarPath = null;
        
        DebugLogger.success(
          'Avatar başarıyla silindi',
          tag: 'PROFILE_PROVIDER',
        );
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('Avatar silme hatası: $e');
      DebugLogger.error(
        'Avatar silme hatası: $e',
        tag: 'PROFILE_PROVIDER',
      );
      return false;
    } finally {
      _setLoadingAvatar(false);
    }
  }

  /// Avatar widget'ı oluştur
  Future<Widget> buildAvatarWidget({
    required double size,
    Color? backgroundColor,
    Color? iconColor,
  }) async {
    return await _avatarService.buildAvatarWidget(
      size: size,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
    );
  }

  /// Varsayılan avatar widget'ı oluştur
  Widget buildDefaultAvatar({
    required double size,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return _avatarService.buildDefaultAvatar(
      size: size,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
    );
  }

  /// Avatar var mı kontrol et
  Future<bool> hasAvatar() async {
    return await _avatarService.hasAvatar();
  }

  /// Günlük su hedefini hesapla (mevcut UserProvider verilerini kullan)
  double calculateDailyWaterNeed() {
    // Şimdilik UserProvider'daki mevcut hedefi döndür
    // İleride HydrationGoalService ile entegre edilebilir
    return _userProvider.dailyWaterGoal;
  }

  /// Profil verilerini yenile
  Future<void> refreshProfileData() async {
    try {
      _clearError();
      
      // Avatar'ı yeniden yükle
      await _loadAvatar();
      
      // Diğer provider'ları yenile (gerekirse)
      // BadgeProvider ve NotificationProvider kendi stream'lerini dinliyor
      
      DebugLogger.success(
        'Profil verileri yenilendi',
        tag: 'PROFILE_PROVIDER',
      );
    } catch (e) {
      _setError('Profil verileri yenileme hatası: $e');
      DebugLogger.error(
        'Profil verileri yenileme hatası: $e',
        tag: 'PROFILE_PROVIDER',
      );
    }
  }

  // Event handlers
  void _onUserDataChanged() {
    // UserProvider değiştiğinde UI'ı güncelle
    notifyListeners();
  }

  void _onNotificationSettingsChanged() {
    // NotificationProvider değiştiğinde UI'ı güncelle
    notifyListeners();
  }

  void _onBadgeDataChanged() {
    // BadgeProvider değiştiğinde UI'ı güncelle
    notifyListeners();
  }

  // Helper methods
  void _setLoadingAvatar(bool loading) {
    _isLoadingAvatar = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Debug bilgilerini yazdır
  void debugPrintProfileInfo() {
    DebugLogger.info(
      '''
📋 Profil Bilgileri:
👤 Ad: $displayName
💧 Günlük Hedef: $dailyGoalFormatted
🔔 Bildirimler: $notificationStatusText
🏆 Rozetler: $badgeStatusText
🖼️ Avatar: ${_avatarPath != null ? 'Var' : 'Yok'}
      ''',
      tag: 'PROFILE_PROVIDER',
    );
  }
}
