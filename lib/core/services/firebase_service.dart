import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../firebase_options.dart';

/// Firebase servislerini yöneten singleton sınıf
class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  bool _isInitialized = false;

  /// Firebase'i güvenli bir şekilde initialize et
  Future<void> initializeFirebase() async {
    if (_isInitialized) {
      return; // Zaten initialize edilmiş
    }

    try {
      // Firebase'i kontrol et ve initialize et
      try {
        Firebase.app();
      } catch (e) {
        // Firebase app yok, yeni bir tane oluştur
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // Firebase Messaging'i başlat
      await _initializeMessaging();

      // İzinleri iste
      await _requestPermissions();

      _isInitialized = true;
    } catch (e) {
      print('Firebase initialization error: $e');
      rethrow;
    }
  }

  /// Firebase Messaging'i başlat
  Future<void> _initializeMessaging() async {
    try {
      // Background message handler'ı kaydet
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Foreground message handler'ı kaydet
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground message received: ${message.messageId}');
      });
    } catch (e) {
      print('Firebase Messaging initialization error: $e');
    }
  }

  /// İzinleri iste
  Future<void> _requestPermissions() async {
    try {
      await Permission.notification.request();
    } catch (e) {
      print('Permission request error: $e');
    }
  }

  /// Firebase'in initialize edilip edilmediğini kontrol et
  bool get isInitialized => _isInitialized;
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.messageId}');
}
