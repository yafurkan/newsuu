import 'package:flutter/material.dart';
import '../../data/services/hive_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/models/notification_settings_model.dart';

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
      if (_settings.isEnabled) {
        await _notificationService.scheduleRepeatingNotifications(_settings);
        print('📅 Bildirimler planlandı');
      } else {
        await _notificationService.cancelAllNotifications();
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
}
