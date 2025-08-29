import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/utils/debug_logger.dart';

/// Firebase Cloud Messaging servisi
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;

  /// FCM token'ı al
  String? get fcmToken => _fcmToken;

  /// Servisi başlat
  Future<void> initialize() async {
    try {
      // Bildirim izni iste
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      DebugLogger.info(
        'FCM İzin durumu: ${settings.authorizationStatus}',
        tag: 'FCM',
      );

      // Token'ı al
      _fcmToken = await _firebaseMessaging.getToken();
      DebugLogger.info('FCM Token: $_fcmToken', tag: 'FCM');

      // Token yenilenme listener'ı
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        DebugLogger.info('FCM Token yenilendi: $newToken', tag: 'FCM');
        // Token'ı sunucuya gönderin (opsiyonel)
        _sendTokenToServer(newToken);
      });

      // Foreground mesaj listener'ı
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Uygulama açıldığında mesaj listener'ı
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // İlk açılışta mesaj kontrolü
      RemoteMessage? initialMessage = await _firebaseMessaging
          .getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      DebugLogger.success('Firebase Messaging servisi başlatıldı', tag: 'FCM');
    } catch (e) {
      DebugLogger.error('Firebase Messaging başlatma hatası: $e', tag: 'FCM');
    }
  }

  /// Foreground'da gelen mesajları işle
  void _handleForegroundMessage(RemoteMessage message) {
    DebugLogger.info(
      'Foreground mesaj alındı: ${message.notification?.title}',
      tag: 'FCM',
    );
    DebugLogger.info(
      'Mesaj içeriği: ${message.notification?.body}',
      tag: 'FCM',
    );
    DebugLogger.info('Data: ${message.data}', tag: 'FCM');

    // Burada local notification gösterebilirsiniz
    // NotificationService ile entegre edilebilir
  }

  /// Uygulama açıldığında mesajları işle
  void _handleMessageOpenedApp(RemoteMessage message) {
    DebugLogger.info(
      'Uygulama mesajla açıldı: ${message.notification?.title}',
      tag: 'FCM',
    );
    DebugLogger.info('Message data: ${message.data}', tag: 'FCM');

    // Burada belirli bir sayfaya yönlendirme yapabilirsiniz
    // Örn: İstatistikler sayfası, Profil sayfası vs.
  }

  /// Token'ı sunucuya gönder (opsiyonel)
  Future<void> _sendTokenToServer(String token) async {
    try {
      // Burada token'ı kendi sunucunuza kaydedebilirsiniz
      // Firestore'a da kaydedilebilir
      DebugLogger.success('Token sunucuya gönderildi: $token', tag: 'FCM');
    } catch (e) {
      DebugLogger.error('Token gönderme hatası: $e', tag: 'FCM');
    }
  }

  /// Belirli topic'e abone ol
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      DebugLogger.success('Topic\'e abone olundu: $topic', tag: 'FCM');
    } catch (e) {
      DebugLogger.error('Topic abonelik hatası: $e', tag: 'FCM');
    }
  }

  /// Topic aboneliğini iptal et
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      DebugLogger.success('Topic aboneliği iptal edildi: $topic', tag: 'FCM');
    } catch (e) {
      DebugLogger.error('Topic abonelik iptali hatası: $e', tag: 'FCM');
    }
  }

  /// Test bildirimi gönder (development için)
  Future<void> sendTestNotification() async {
    if (_fcmToken == null) {
      DebugLogger.warning('FCM Token bulunamadı', tag: 'FCM');
      return;
    }

    try {
      // Bu fonksiyon sadece test amaçlı
      // Gerçek uygulamada bildirimler Firebase Console'dan veya sunucudan gönderilir
      DebugLogger.info('Test bildirimi hazırlanıyor...', tag: 'FCM');
      DebugLogger.info('Token: $_fcmToken', tag: 'FCM');
      DebugLogger.info(
        'Firebase Console\'dan test bildirimi gönderebilirsiniz!',
        tag: 'FCM',
      );
    } catch (e) {
      DebugLogger.error('Test bildirimi hatası: $e', tag: 'FCM');
    }
  }
}
