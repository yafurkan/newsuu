import 'package:firebase_messaging/firebase_messaging.dart';

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

      print('📱 FCM İzin durumu: ${settings.authorizationStatus}');

      // Token'ı al
      _fcmToken = await _firebaseMessaging.getToken();
      print('🔑 FCM Token: $_fcmToken');

      // Token yenilenme listener'ı
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        print('🔄 FCM Token yenilendi: $newToken');
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

      print('✅ Firebase Messaging servisi başlatıldı');
    } catch (e) {
      print('❌ Firebase Messaging başlatma hatası: $e');
    }
  }

  /// Foreground'da gelen mesajları işle
  void _handleForegroundMessage(RemoteMessage message) {
    print('🔔 Foreground mesaj alındı: ${message.notification?.title}');
    print('📝 Mesaj içeriği: ${message.notification?.body}');
    print('📊 Data: ${message.data}');

    // Burada local notification gösterebilirsiniz
    // NotificationService ile entegre edilebilir
  }

  /// Uygulama açıldığında mesajları işle
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('🚀 Uygulama mesajla açıldı: ${message.notification?.title}');
    print('📊 Message data: ${message.data}');

    // Burada belirli bir sayfaya yönlendirme yapabilirsiniz
    // Örn: İstatistikler sayfası, Profil sayfası vs.
  }

  /// Token'ı sunucuya gönder (opsiyonel)
  Future<void> _sendTokenToServer(String token) async {
    try {
      // Burada token'ı kendi sunucunuza kaydedebilirsiniz
      // Firestore'a da kaydedilebilir
      print('📤 Token sunucuya gönderildi: $token');
    } catch (e) {
      print('❌ Token gönderme hatası: $e');
    }
  }

  /// Belirli topic'e abone ol
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Topic\'e abone olundu: $topic');
    } catch (e) {
      print('❌ Topic abonelik hatası: $e');
    }
  }

  /// Topic aboneliğini iptal et
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('❌ Topic aboneliği iptal edildi: $topic');
    } catch (e) {
      print('❌ Topic abonelik iptali hatası: $e');
    }
  }

  /// Test bildirimi gönder (development için)
  Future<void> sendTestNotification() async {
    if (_fcmToken == null) {
      print('❌ FCM Token bulunamadı');
      return;
    }

    try {
      // Bu fonksiyon sadece test amaçlı
      // Gerçek uygulamada bildirimler Firebase Console'dan veya sunucudan gönderilir
      print('🧪 Test bildirimi hazırlanıyor...');
      print('🔑 Token: $_fcmToken');
      print('💡 Firebase Console\'dan test bildirimi gönderebilirsiniz!');
    } catch (e) {
      print('❌ Test bildirimi hatası: $e');
    }
  }
}
