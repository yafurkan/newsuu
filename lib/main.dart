import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';
import 'data/services/notification_service.dart';
import 'data/services/cloud_sync_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/water_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'core/utils/debug_logger.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  DebugLogger.info(
    'Background message received: ${message.messageId}',
    tag: 'MAIN',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase'i kontrollü şekilde initialize et
    await _initializeFirebase();

    // İzinleri iste
    await Permission.notification.request();

    // Notification service'i initialize et
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Cloud sync service'i initialize et
    final cloudSyncService = CloudSyncService();

    runApp(
      SuTakipApp(
        notificationService: notificationService,
        cloudSyncService: cloudSyncService,
      ),
    );
  } catch (e) {
    DebugLogger.error('Firebase initialization error: $e', tag: 'MAIN');
    // Firebase hatası olsa da normal uygulamayı çalıştır

    // Basit servisler oluştur
    final notificationService = NotificationService();
    final cloudSyncService = CloudSyncService();

    runApp(
      SuTakipApp(
        notificationService: notificationService,
        cloudSyncService: cloudSyncService,
      ),
    );
  }
}

Future<void> _initializeFirebase() async {
  try {
    // Önce tüm mevcut Firebase app'larını listele
    final apps = Firebase.apps;
    DebugLogger.info('Existing Firebase apps: ${apps.length}', tag: 'MAIN');

    // Eğer DEFAULT app varsa onu kullan
    if (apps.any((app) => app.name == '[DEFAULT]')) {
      DebugLogger.info(
        'DEFAULT Firebase app already exists, using it.',
        tag: 'MAIN',
      );
      return;
    }

    // Eğer hiç app yoksa veya DEFAULT yoksa yeni bir tane oluştur
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Background message handler'ı kaydet
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    DebugLogger.success('Firebase initialized successfully', tag: 'MAIN');
  } catch (e) {
    DebugLogger.error('Firebase initialization failed: $e', tag: 'MAIN');
    rethrow;
  }
}

class SuTakipApp extends StatefulWidget {
  final NotificationService notificationService;
  final CloudSyncService cloudSyncService;

  const SuTakipApp({
    super.key,
    required this.notificationService,
    required this.cloudSyncService,
  });

  @override
  State<SuTakipApp> createState() => _SuTakipAppState();
}

class _SuTakipAppState extends State<SuTakipApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // Uygulama ön plana geldiğinde günlük geçişi kontrol et
      // Provider'ı güvenli şekilde alabilmek için try-catch kullan
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final waterProvider = context.read<WaterProvider>();
          waterProvider.refreshData();
        } catch (e) {
          DebugLogger.error('WaterProvider bulunamadı: $e', tag: 'MAIN');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NotificationService>.value(value: widget.notificationService),
        Provider<CloudSyncService>.value(value: widget.cloudSyncService),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProvider(widget.cloudSyncService),
        ),
        ChangeNotifierProxyProvider<UserProvider, WaterProvider>(
          create: (context) => WaterProvider(widget.cloudSyncService),
          update: (context, userProvider, waterProvider) {
            // UserProvider'daki hedef değişikliğini WaterProvider'a aktar
            waterProvider?.updateGoalFromUserProvider(
              userProvider.dailyWaterGoal,
            );
            return waterProvider!;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(
            widget.notificationService,
            widget.cloudSyncService,
          ),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: 'Su Takip',
            theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
