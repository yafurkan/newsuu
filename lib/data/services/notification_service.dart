import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import '../models/notification_settings_model.dart';
import '../../core/constants/notification_messages.dart';
import '../../core/utils/debug_logger.dart';

/// Bildirim yönetimi servisi
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Bildirim servisini başlat
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Timezone'ları başlat
      tz.initializeTimeZones();

      // Android ayarları
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS ayarları
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Yüksek öncelikli bildirim kanalı oluştur
      await _createHighImportanceChannel();

      // İzin iste
      await _requestPermissions();

      _isInitialized = true;
      DebugLogger.success(
        'Bildirim servisi başarıyla başlatıldı',
        tag: 'NOTIFICATION',
      );
    } catch (e) {
      DebugLogger.error(
        'Bildirim servisi başlatma hatası: $e',
        tag: 'NOTIFICATION',
      );
    }
  }

  /// Yüksek öncelikli bildirim kanalı oluştur
  Future<void> _createHighImportanceChannel() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'Su Takip Bildirimleri',
        description: 'Su içme hatırlatmaları ve önemli bildirimler',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      DebugLogger.success(
        'Yüksek öncelikli bildirim kanalı oluşturuldu',
        tag: 'NOTIFICATION',
      );
    } catch (e) {
      DebugLogger.error(
        'Bildirim kanalı oluşturma hatası: $e',
        tag: 'NOTIFICATION',
      );
    }
  }

  /// Bildirim izinlerini iste
  Future<void> _requestPermissions() async {
    try {
      DebugLogger.info(
        'Bildirim izinleri kontrol ediliyor...',
        tag: 'NOTIFICATION',
      );

      // Android 13+ için POST_NOTIFICATIONS izni
      final notificationStatus = await Permission.notification.status;
      DebugLogger.info(
        'Bildirim izin durumu: $notificationStatus',
        tag: 'NOTIFICATION',
      );

      if (notificationStatus.isDenied) {
        DebugLogger.info('Bildirim izni isteniyor...', tag: 'NOTIFICATION');
        final result = await Permission.notification.request();
        DebugLogger.info('İzin sonucu: $result', tag: 'NOTIFICATION');

        if (result.isGranted) {
          DebugLogger.success('Bildirim izni verildi', tag: 'NOTIFICATION');
        } else if (result.isDenied) {
          DebugLogger.warning('Bildirim izni reddedildi', tag: 'NOTIFICATION');
        } else if (result.isPermanentlyDenied) {
          DebugLogger.warning(
            'Bildirim izni kalıcı olarak reddedildi',
            tag: 'NOTIFICATION',
          );
        }
      } else if (notificationStatus.isGranted) {
        DebugLogger.success(
          'Bildirim izni zaten verilmiş',
          tag: 'NOTIFICATION',
        );
      }

      // iOS için izin iste
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      // Android için izin iste
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (e) {
      DebugLogger.error('Bildirim izni hatası: $e', tag: 'NOTIFICATION');
    }
  }

  /// Bildirim tıklandığında çalışacak fonksiyon
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    DebugLogger.info(
      'Bildirim tıklandı: ${notificationResponse.payload}',
      tag: 'NOTIFICATION',
    );
    // Buraya bildirim tıklandığında yapılacak işlemler eklenebilir
  }

  /// Anında bildirim gönder
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
    bool withSound = true,
    bool withVibration = true,
  }) async {
    try {
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // Yüksek öncelikli kanal
            'Su Takip Bildirimleri',
            channelDescription: 'Su içme hatırlatmaları ve önemli bildirimler',
            importance: Importance.max,
            priority: Priority.high,
            playSound: withSound,
            enableVibration: withVibration,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF4A90E2),
            showWhen: true,
            when: DateTime.now().millisecondsSinceEpoch,
            autoCancel: false, // Kullanıcı kapatana kadar kalır
            ongoing: false,
            showProgress: false,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: withSound,
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      DebugLogger.error('Anında bildirim hatası: $e', tag: 'NOTIFICATION');
    }
  }

  /// Zamanlanmış bildirim ayarla
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    bool withSound = true,
    bool withVibration = true,
  }) async {
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminder',
            'Su Hatırlatma',
            channelDescription: 'Su içme hatırlatmaları',
            importance: Importance.high,
            priority: Priority.high,
            playSound: withSound,
            enableVibration: withVibration,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF4A90E2),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: withSound,
          ),
        ),
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      DebugLogger.error('Zamanlanmış bildirim hatası: $e', tag: 'NOTIFICATION');
    }
  }

  /// Tekrarlayan bildirim ayarla
  Future<void> scheduleRepeatingNotifications(
    NotificationSettings settings,
  ) async {
    try {
      // Önce tüm bildirimleri iptal et
      await cancelAllNotifications();

      if (!settings.isEnabled) return;

      // Her gün için bildirimleri ayarla
      DebugLogger.info(
        'Selected days: ${settings.selectedDays}',
        tag: 'NOTIFICATION',
      );
      DebugLogger.info(
        'Selected days type: ${settings.selectedDays.runtimeType}',
        tag: 'NOTIFICATION',
      );

      // Güvenli bir liste kopyası oluştur
      final daysList = List<int>.from(settings.selectedDays);

      for (int day in daysList) {
        await _scheduleNotificationsForDay(day, settings);
      }

      DebugLogger.success(
        'Tekrarlayan bildirimler ayarlandı',
        tag: 'NOTIFICATION',
      );
    } catch (e) {
      DebugLogger.error(
        'Tekrarlayan bildirim ayarlama hatası: $e',
        tag: 'NOTIFICATION',
      );
    }
  }

  /// Belirli bir gün için bildirimleri ayarla
  Future<void> _scheduleNotificationsForDay(
    int weekday,
    NotificationSettings settings,
  ) async {
    try {
      final now = DateTime.now();

      // Bir sonraki bu günü bul
      DateTime nextDay = now;
      while (nextDay.weekday != weekday) {
        nextDay = nextDay.add(const Duration(days: 1));
      }

      // Bildirim saatlerini hesapla
      List<int> notificationHours = <int>[];

      // Eğer özel zaman dilimleri seçilmemişse, saatlik aralıkla bildirim ekle
      bool hasSpecialTimes =
          settings.morningEnabled ||
          settings.afternoonEnabled ||
          settings.eveningEnabled;

      if (!hasSpecialTimes) {
        // Saat aralığında bildirim saatlerini oluştur
        for (
          int hour = settings.startHour;
          hour <= settings.endHour;
          hour += settings.intervalHours
        ) {
          notificationHours.add(hour);
        }
      } else {
        // Özel zaman dilimi bildirimleri
        if (settings.morningEnabled) {
          notificationHours.add(7);
          notificationHours.add(9);
        }
        if (settings.afternoonEnabled) {
          notificationHours.add(12);
          notificationHours.add(15);
        }
        if (settings.eveningEnabled) {
          notificationHours.add(18);
          notificationHours.add(20);
        }
      }

      // Dublicatları kaldır ve sırala
      final uniqueHours = List<int>.from(notificationHours.toSet());
      uniqueHours.sort();

      DebugLogger.info(
        'Gün $weekday için bildirim saatleri: $uniqueHours',
        tag: 'NOTIFICATION',
      );
      DebugLogger.info(
        'Ayarlar - Başlangıç: ${settings.startHour}, Bitiş: ${settings.endHour}, Aralık: ${settings.intervalHours}',
        tag: 'NOTIFICATION',
      );
      DebugLogger.info(
        'Özel zamanlar - Sabah: ${settings.morningEnabled}, Öğlen: ${settings.afternoonEnabled}, Akşam: ${settings.eveningEnabled}',
        tag: 'NOTIFICATION',
      );

      // Her saat için bildirim ayarla
      for (int hour in uniqueHours) {
        if (hour >= settings.startHour && hour <= settings.endHour) {
          final scheduledTime = DateTime(
            nextDay.year,
            nextDay.month,
            nextDay.day,
            hour,
            Random().nextInt(60), // Rastgele dakika
          );

          final message = NotificationMessages.getHourlyMessage(hour);

          await scheduleNotification(
            id: (weekday * 100) + hour, // Benzersiz ID
            title: '💧 Su İçme Zamanı!',
            body: message,
            scheduledTime: scheduledTime,
            withSound: settings.soundEnabled,
            withVibration: settings.vibrationEnabled,
          );

          DebugLogger.info(
            'Bildirim ayarlandı: ${scheduledTime.toString()} - $message',
            tag: 'NOTIFICATION',
          );
        }
      }
    } catch (e) {
      DebugLogger.error(
        'Gün $weekday için bildirim ayarlama hatası: $e',
        tag: 'NOTIFICATION',
      );
      DebugLogger.error(
        'Stack trace: ${StackTrace.current}',
        tag: 'NOTIFICATION',
      );
    }
  }

  /// Tüm bildirimleri iptal et
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      DebugLogger.success('Tüm bildirimler iptal edildi', tag: 'NOTIFICATION');
    } catch (e) {
      DebugLogger.error('Bildirim iptal etme hatası: $e', tag: 'NOTIFICATION');
    }
  }

  /// Belirli bir bildirimi iptal et
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      DebugLogger.error('Bildirim iptal etme hatası: $e', tag: 'NOTIFICATION');
    }
  }

  /// Bekleyen bildirimleri listele
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
    } catch (e) {
      DebugLogger.error(
        'Bekleyen bildirimler alınırken hata: $e',
        tag: 'NOTIFICATION',
      );
      return [];
    }
  }

  /// Test bildirimi gönder
  Future<void> sendTestNotification() async {
    final message = NotificationMessages.getRandomMessage();
    await showInstantNotification(title: '🧪 Test Bildirimi', body: message);
  }

  /// Su içildiğinde tebrik bildirimi
  Future<void> sendCongratulationNotification(double amount) async {
    final messages = [
      '🎉 Harika! ${amount.toInt()} ml su içtin!',
      '👏 Aferin! Vücudun teşekkür ediyor!',
      '🌟 Mükemmel! Hedefe bir adım daha yaklaştın!',
      '💪 Süper! Sağlıklı yaşam tarzını sürdürüyorsun!',
      '🎯 Bravo! Su hedefine ulaşmak için devam et!',
    ];

    messages.shuffle();
    await showInstantNotification(
      title: '🎊 Tebrikler!',
      body: messages.first,
      withSound: false, // Ses olmadan
    );
  }

  /// Hedef tamamlandığında bildirim
  Future<void> sendGoalCompletedNotification() async {
    await showInstantNotification(
      title: '🏆 Günlük Hedef Tamamlandı!',
      body: '🎉 Bugünkü su hedefini başarıyla tamamladın! Muhteşem!',
    );
  }
}
