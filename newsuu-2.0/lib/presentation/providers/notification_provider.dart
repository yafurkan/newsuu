import 'package:flutter/material.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/cloud_sync_service.dart';
import '../../data/models/notification_settings_model.dart';
import '../../core/constants/notification_messages.dart';
import '../../core/utils/debug_logger.dart';

/// Bildirim ayarlarını yöneten Provider sınıfı (Firebase entegreli)
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  final CloudSyncService _cloudSyncService;

  NotificationSettings _settings = NotificationSettings();
  bool _isLoading = false;
  String? _errorMessage;

  NotificationProvider(this._notificationService, this._cloudSyncService) {
    _loadSettings();
  }

  // Getters
  NotificationSettings get settings => _settings;
  bool get isEnabled => _settings.isEnabled;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Ayarları yükle (Firebase'den)
  Future<void> _loadSettings() async {
    try {
      _setLoading(true);
      _clearError();

      // Firebase'den bildirim ayarlarını al
      final firebaseSettings = await _cloudSyncService
          .getNotificationSettings();

      if (firebaseSettings != null) {
        _settings = firebaseSettings;
        DebugLogger.info(
          '✅ Bildirim ayarları Firebase\'den yüklendi',
          tag: 'NOTIFICATION_PROVIDER',
        );
      } else {
        // Varsayılan ayarları kullan ve Firebase'e kaydet
        _settings = NotificationSettings();
        await _cloudSyncService.saveNotificationSettings(_settings);
        DebugLogger.info(
          '✅ Varsayılan bildirim ayarları Firebase\'e kaydedildi',
          tag: 'NOTIFICATION_PROVIDER',
        );
      }

      // Bildirimleri ayarla
      await _scheduleNotifications();
      notifyListeners();
    } catch (e) {
      _setError('Bildirim ayarları yükleme hatası: $e');
      DebugLogger.info(
        '❌ Bildirim ayarları yükleme hatası: $e',
        tag: 'NOTIFICATION_PROVIDER',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Ayarları kaydet (Firebase'e)
  Future<void> _saveSettings() async {
    try {
      _setLoading(true);
      _clearError();

      // Firebase'e kaydet
      await _cloudSyncService.saveNotificationSettings(_settings);
      DebugLogger.info(
        '💾 Bildirim ayarları Firebase\'e kaydedildi',
        tag: 'NOTIFICATION_PROVIDER',
      );
    } catch (e) {
      _setError('Bildirim ayarları kaydetme hatası: $e');
      DebugLogger.info(
        '❌ Bildirim ayarları kaydetme hatası: $e',
        tag: 'NOTIFICATION_PROVIDER',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Ayarları güncelle
  Future<void> updateSettings(NotificationSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    await _scheduleNotifications();
    notifyListeners();
  }

  /// Bildirimleri planla
  Future<void> _scheduleNotifications() async {
    try {
      // Önce tüm bildirimleri iptal et
      await _notificationService.cancelAllNotifications();

      if (_settings.isEnabled && _settings.intervalEnabled) {
        // Sıklık bazlı bildirimler (yalnızca intervalEnabled true ise)
        await _notificationService.scheduleRepeatingNotifications(_settings);
        DebugLogger.info(
          '📅 Sıklık bazlı bildirimler planlandı',
          tag: 'NOTIFICATION_PROVIDER',
        );
      }

      // Akıllı günlük bildirimler (sıklık açık olmasa da çalışır)
      if (_settings.morningEnabled ||
          _settings.afternoonEnabled ||
          _settings.eveningEnabled) {
        await _scheduleDailySmartNotifications();
        DebugLogger.info(
          '🧠 Akıllı günlük bildirimler planlandı',
          tag: 'NOTIFICATION_PROVIDER',
        );
      }

      if (!_settings.isEnabled &&
          !_settings.morningEnabled &&
          !_settings.afternoonEnabled &&
          !_settings.eveningEnabled) {
        DebugLogger.info(
          '🔕 Tüm bildirimler iptal edildi',
          tag: 'NOTIFICATION_PROVIDER',
        );
      }
    } catch (e) {
      DebugLogger.info(
        '❌ Bildirim planlama hatası: $e',
        tag: 'NOTIFICATION_PROVIDER',
      );
    }
  }

  /// Bildirimleri yeniden planla
  Future<void> rescheduleNotifications() async {
    await _scheduleNotifications();
  }

  /// Bildirim durumunu değiştir
  Future<void> toggleNotifications() async {
    await updateSettings(_settings.copyWith(isEnabled: !_settings.isEnabled));
  }

  /// Bildirim sıklığını değiştir
  Future<void> setNotificationInterval(int hours) async {
    await updateSettings(_settings.copyWith(intervalHours: hours));
  }

  /// Zaman aralığını değiştir
  Future<void> setTimeRange(int startHour, int endHour) async {
    await updateSettings(
      _settings.copyWith(startHour: startHour, endHour: endHour),
    );
  }

  /// Özel zaman dilimlerini ayarla
  Future<void> setSpecialTimes({
    bool? morning,
    bool? afternoon,
    bool? evening,
  }) async {
    await updateSettings(
      _settings.copyWith(
        morningEnabled: morning,
        afternoonEnabled: afternoon,
        eveningEnabled: evening,
      ),
    );
  }

  /// Aktif günleri ayarla
  Future<void> setActiveDays(List<int> days) async {
    await updateSettings(_settings.copyWith(selectedDays: days));
  }

  /// Ses ayarlarını değiştir
  Future<void> setSoundSettings({bool? sound, bool? vibration}) async {
    await updateSettings(
      _settings.copyWith(soundEnabled: sound, vibrationEnabled: vibration),
    );
  }

  /// Test bildirimi gönder
  Future<void> sendTestNotification() async {
    try {
      await _notificationService.showInstantNotification(
        title: '💧 Su Takip - Test',
        body: 'Bildirim sistemi çalışıyor! Su içmeyi unutma! 😊',
        payload: 'test_notification',
      );
      DebugLogger.info(
        '✅ Test bildirimi gönderildi',
        tag: 'NOTIFICATION_PROVIDER',
      );
    } catch (e) {
      DebugLogger.info(
        '❌ Test bildirimi hatası: $e',
        tag: 'NOTIFICATION_PROVIDER',
      );
      rethrow;
    }
  }

  /// Tebrik bildirimi gönder
  Future<void> sendCongratulationNotification(double amount) async {
    await _notificationService.sendCongratulationNotification(amount);
  }

  /// Hedef tamamlama bildirimi gönder
  Future<void> sendGoalCompletedNotification() async {
    await _notificationService.sendGoalCompletedNotification();
  }

  /// Bekleyen bildirimleri getir
  Future<int> getPendingNotificationsCount() async {
    final pending = await _notificationService.getPendingNotifications();
    return pending.length;
  }

  /// Ayarları sıfırla
  Future<void> resetSettings() async {
    _settings = NotificationSettings();
    await _saveSettings();
    await _scheduleNotifications();
    notifyListeners();
  }

  /// Ayarları Firebase'den yeniden yükle
  Future<void> refreshSettings() async {
    await _loadSettings();
  }

  /// Ayarları Firebase'den sil
  Future<void> deleteSettings() async {
    try {
      _setLoading(true);
      _clearError();

      await _cloudSyncService.deleteNotificationSettings();
      _settings = NotificationSettings();
      await _scheduleNotifications();
      notifyListeners();

      DebugLogger.info(
        '🗑️ Bildirim ayarları Firebase\'den silindi',
        tag: 'NOTIFICATION_PROVIDER',
      );
    } catch (e) {
      _setError('Bildirim ayarları silme hatası: $e');
      DebugLogger.info(
        '❌ Bildirim ayarları silme hatası: $e',
        tag: 'NOTIFICATION_PROVIDER',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Bildirim iznini kontrol et
  Future<bool> checkNotificationPermission() async {
    // Bu metod permission_handler kullanarak gerçek izin kontrolü yapabilir
    return true;
  }

  /// Bildirim izni iste
  Future<void> requestNotificationPermission() async {
    // Bu metod permission_handler kullanarak izin isteyebilir
    await _notificationService.initialize();
  }

  // 🎯 YENİ: Akıllı Günlük Bildirim Sistemi

  /// Günlük 3 akıllı bildirim zamanla (Firebase entegrasyonu hazır)
  Future<void> _scheduleDailySmartNotifications() async {
    if (!_settings.morningEnabled &&
        !_settings.afternoonEnabled &&
        !_settings.eveningEnabled) {
      DebugLogger.info(
        'Özel zaman dilimleri kapalı, günlük akıllı bildirimler planlanmadı',
        tag: 'NOTIFICATION_PROVIDER',
      );
      return;
    }

    try {
      // Mevcut bildirimleri iptal et
      await _notificationService.cancelAllNotifications();

      final notifications = NotificationMessages.getDailySmartNotifications();

      // Sabah bildirimi (09:00)
      if (_settings.morningEnabled) {
        await _scheduleTimeBasedNotification(
          id: 901, // Özel ID
          hour: 9,
          minute: 0,
          title: notifications['morning']!['title']!,
          body: notifications['morning']!['message']!,
        );
        DebugLogger.info(
          '🌅 Sabah akıllı bildirimi zamanlandı: 09:00',
          tag: 'NOTIFICATION_PROVIDER',
        );
      }

      // Öğle bildirimi (14:00)
      if (_settings.afternoonEnabled) {
        await _scheduleTimeBasedNotification(
          id: 902, // Özel ID
          hour: 14,
          minute: 0,
          title: notifications['afternoon']!['title']!,
          body: notifications['afternoon']!['message']!,
        );
        DebugLogger.info(
          '🌞 Öğle akıllı bildirimi zamanlandı: 14:00',
          tag: 'NOTIFICATION_PROVIDER',
        );
      }

      // Akşam bildirimi (20:00)
      if (_settings.eveningEnabled) {
        await _scheduleTimeBasedNotification(
          id: 903, // Özel ID
          hour: 20,
          minute: 0,
          title: notifications['evening']!['title']!,
          body: notifications['evening']!['message']!,
        );
        DebugLogger.info(
          '🌆 Akşam akıllı bildirimi zamanlandı: 20:00',
          tag: 'NOTIFICATION_PROVIDER',
        );
      }

      DebugLogger.info(
        '✅ Günlük akıllı bildirimler başarıyla zamanlandı',
        tag: 'NOTIFICATION_PROVIDER',
      );
    } catch (e) {
      DebugLogger.info(
        '❌ Günlük akıllı bildirim zamanlama hatası: $e',
        tag: 'NOTIFICATION_PROVIDER',
      );
    }
  }

  /// Belirli saatte bildirim zamanla
  Future<void> _scheduleTimeBasedNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    try {
      await _notificationService.scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledTime: _getNextScheduledTime(hour, minute),
        payload: 'smart_daily_$id',
      );
    } catch (e) {
      DebugLogger.info(
        '❌ Zaman tabanlı bildirim zamanlama hatası: $e',
        tag: 'NOTIFICATION_PROVIDER',
      );
    }
  }

  /// Sonraki bildirim zamanını hesapla
  DateTime _getNextScheduledTime(int hour, int minute) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    // Eğer bugünkü saat geçmişse, yarına ayarla
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Test için anında akıllı bildirim gönder
  Future<void> sendSmartTestNotification() async {
    try {
      final smartMessage = NotificationMessages.getTimeBasedSmartMessage();
      final hour = DateTime.now().hour;

      String title;
      if (hour >= 7 && hour < 12) {
        title = 'Sabah Su Zamanı! 🌅';
      } else if (hour >= 12 && hour < 18) {
        title = 'Öğle Su Molası! 🌞';
      } else if (hour >= 18 && hour <= 22) {
        title = 'Akşam Su Hatırlatması! 🌆';
      } else {
        title = 'Su İçme Zamanı! 💧';
      }

      await _notificationService.showInstantNotification(
        title: title,
        body: smartMessage,
        payload: 'smart_test',
      );

      DebugLogger.info(
        '✅ Akıllı test bildirimi gönderildi: $smartMessage',
        tag: 'NOTIFICATION_PROVIDER',
      );
    } catch (e) {
      DebugLogger.info(
        '❌ Akıllı test bildirimi hatası: $e',
        tag: 'NOTIFICATION_PROVIDER',
      );
    }
  }

  /// Bildirim sıklığını açar/kapatır
  Future<void> toggleIntervalNotifications() async {
    await updateSettings(
      _settings.copyWith(intervalEnabled: !_settings.intervalEnabled),
    );
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
}
