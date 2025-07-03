import 'package:flutter/material.dart';
import '../../data/services/hive_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/models/notification_settings_model.dart';
import '../../core/constants/notification_messages.dart';

/// Bildirim ayarlarını yöneten Provider sınıfı
class NotificationProvider extends ChangeNotifier {
  final HiveService _hiveService;
  final NotificationService _notificationService;

  NotificationSettings _settings = NotificationSettings();

  NotificationProvider(this._hiveService, this._notificationService) {
    _loadSettings();
  }

  // Getters
  NotificationSettings get settings => _settings;
  bool get isEnabled => _settings.isEnabled;

  /// Ayarları Hive'dan yükle
  Future<void> _loadSettings() async {
    try {
      final savedSettingsJson = _hiveService.getNotificationSettings();
      if (savedSettingsJson != null) {
        _settings = NotificationSettings.fromJson(savedSettingsJson);
        print('✅ Bildirim ayarları yüklendi');
      } else {
        // İlk kez kullanım - varsayılan ayarları kaydet
        await _saveSettings();
        print('📱 Varsayılan bildirim ayarları kaydedildi');
      }

      // Bildirimleri ayarla
      await _scheduleNotifications();
      notifyListeners();
    } catch (e) {
      print('❌ Bildirim ayarları yükleme hatası: $e');
    }
  }

  /// Ayarları kaydet
  Future<void> _saveSettings() async {
    try {
      await _hiveService.saveNotificationSettings(_settings);
      print('💾 Bildirim ayarları kaydedildi');
    } catch (e) {
      print('❌ Bildirim ayarları kaydetme hatası: $e');
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
        print('📅 Sıklık bazlı bildirimler planlandı');
      }

      // Akıllı günlük bildirimler (sıklık açık olmasa da çalışır)
      if (_settings.morningEnabled ||
          _settings.afternoonEnabled ||
          _settings.eveningEnabled) {
        await _scheduleDailySmartNotifications();
        print('🧠 Akıllı günlük bildirimler planlandı');
      }

      if (!_settings.isEnabled &&
          !_settings.morningEnabled &&
          !_settings.afternoonEnabled &&
          !_settings.eveningEnabled) {
        print('🔕 Tüm bildirimler iptal edildi');
      }
    } catch (e) {
      print('❌ Bildirim planlama hatası: $e');
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
      print('✅ Test bildirimi gönderildi');
    } catch (e) {
      print('❌ Test bildirimi hatası: $e');
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
      print(
        '⏸️ Özel zaman dilimleri kapalı, günlük akıllı bildirimler planlanmadı',
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
        print('🌅 Sabah akıllı bildirimi zamanlandı: 09:00');
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
        print('🌞 Öğle akıllı bildirimi zamanlandı: 14:00');
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
        print('🌆 Akşam akıllı bildirimi zamanlandı: 20:00');
      }

      print('✅ Günlük akıllı bildirimler başarıyla zamanlandı');
    } catch (e) {
      print('❌ Günlük akıllı bildirim zamanlama hatası: $e');
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
      print('❌ Zaman tabanlı bildirim zamanlama hatası: $e');
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

      print('✅ Akıllı test bildirimi gönderildi: $smartMessage');
    } catch (e) {
      print('❌ Akıllı test bildirimi hatası: $e');
    }
  }

  /// Bildirim sıklığını açar/kapatır
  Future<void> toggleIntervalNotifications() async {
    await updateSettings(
      _settings.copyWith(intervalEnabled: !_settings.intervalEnabled),
    );
  }
}
