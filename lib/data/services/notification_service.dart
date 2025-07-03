import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import '../models/notification_settings_model.dart';
import '../../core/constants/notification_messages.dart';

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
      print('📱 Bildirim servisi başarıyla başlatıldı');
    } catch (e) {
      print('❌ Bildirim servisi başlatma hatası: $e');
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

      print('📱 Yüksek öncelikli bildirim kanalı oluşturuldu');
    } catch (e) {
      print('❌ Bildirim kanalı oluşturma hatası: $e');
    }
  }

  /// Bildirim izinlerini iste
  Future<void> _requestPermissions() async {
    try {
      print('🔐 Bildirim izinleri kontrol ediliyor...');

      // Android 13+ için POST_NOTIFICATIONS izni
      final notificationStatus = await Permission.notification.status;
      print('📱 Bildirim izin durumu: $notificationStatus');

      if (notificationStatus.isDenied) {
        print('🔔 Bildirim izni isteniyor...');
        final result = await Permission.notification.request();
        print('📋 İzin sonucu: $result');

        if (result.isGranted) {
          print('✅ Bildirim izni verildi');
        } else if (result.isDenied) {
          print('❌ Bildirim izni reddedildi');
        } else if (result.isPermanentlyDenied) {
          print('🚫 Bildirim izni kalıcı olarak reddedildi');
        }
      } else if (notificationStatus.isGranted) {
        print('✅ Bildirim izni zaten verilmiş');
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
      print('❌ Bildirim izni hatası: $e');
    }
  }

  /// Bildirim tıklandığında çalışacak fonksiyon
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    print('🔔 Bildirim tıklandı: ${notificationResponse.payload}');
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
      print('❌ Anında bildirim hatası: $e');
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
      print('❌ Zamanlanmış bildirim hatası: $e');
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
      print('🔍 Selected days: ${settings.selectedDays}');
      print('🔍 Selected days type: ${settings.selectedDays.runtimeType}');

      // Güvenli bir liste kopyası oluştur
      final daysList = List<int>.from(settings.selectedDays);

      for (int day in daysList) {
        await _scheduleNotificationsForDay(day, settings);
      }

      print('🔔 Tekrarlayan bildirimler ayarlandı');
    } catch (e) {
      print('❌ Tekrarlayan bildirim ayarlama hatası: $e');
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

      print('📅 Gün $weekday için bildirim saatleri: $uniqueHours');
      print(
        '📅 Ayarlar - Başlangıç: ${settings.startHour}, Bitiş: ${settings.endHour}, Aralık: ${settings.intervalHours}',
      );
      print(
        '📅 Özel zamanlar - Sabah: ${settings.morningEnabled}, Öğlen: ${settings.afternoonEnabled}, Akşam: ${settings.eveningEnabled}',
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

          print('⏰ Bildirim ayarlandı: ${scheduledTime.toString()} - $message');
        }
      }
    } catch (e) {
      print('❌ Gün $weekday için bildirim ayarlama hatası: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  /// Tüm bildirimleri iptal et
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('🔕 Tüm bildirimler iptal edildi');
    } catch (e) {
      print('❌ Bildirim iptal etme hatası: $e');
    }
  }

  /// Belirli bir bildirimi iptal et
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      print('❌ Bildirim iptal etme hatası: $e');
    }
  }

  /// Bekleyen bildirimleri listele
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
    } catch (e) {
      print('❌ Bekleyen bildirimler alınırken hata: $e');
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
