import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'data/services/notification_service.dart';
import 'data/services/cloud_sync_service.dart';
import 'data/services/deep_link_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/animated_onboarding_screen.dart';
import 'screens/email_verification_success_screen.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/water_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/statistics_provider.dart';
import 'presentation/providers/badge_provider.dart';
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

    // Locale data'yı initialize et - önce tr_TR dene, sonra fallback'ler
    try {
      await initializeDateFormatting('tr_TR', null);
      DebugLogger.success('Turkish locale initialized', tag: 'MAIN');
    } catch (e) {
      try {
        await initializeDateFormatting('en_US', null);
        DebugLogger.info('English locale initialized as fallback', tag: 'MAIN');
      } catch (e2) {
        await initializeDateFormatting('en', null);
        DebugLogger.info('Default English locale initialized', tag: 'MAIN');
      }
    }

    // İzinleri iste
    await Permission.notification.request();

    // Notification service'i initialize et
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Cloud sync service'i initialize et
    final cloudSyncService = CloudSyncService();

    // Deep link service'i initialize et
    final deepLinkService = DeepLinkService();
    deepLinkService.initialize();

    runApp(
      SuTakipApp(
        notificationService: notificationService,
        cloudSyncService: cloudSyncService,
        deepLinkService: deepLinkService,
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
        deepLinkService: DeepLinkService(),
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
    // Duplicate app hatası spesifik olarak yakala
    if (e.toString().contains('duplicate-app')) {
      DebugLogger.info(
        'Firebase app already exists, continuing...',
        tag: 'MAIN',
      );
      return;
    }
    DebugLogger.error('Firebase initialization failed: $e', tag: 'MAIN');
    rethrow;
  }
}

class SuTakipApp extends StatefulWidget {
  final NotificationService notificationService;
  final CloudSyncService cloudSyncService;
  final DeepLinkService deepLinkService;

  const SuTakipApp({
    super.key,
    required this.notificationService,
    required this.cloudSyncService,
    required this.deepLinkService,
  });

  @override
  State<SuTakipApp> createState() => _SuTakipAppState();
}

class _SuTakipAppState extends State<SuTakipApp> with WidgetsBindingObserver {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Deep link callback'lerini ayarla
    _setupDeepLinkCallbacks();
  }

  /// Deep link callback'lerini ayarla
  void _setupDeepLinkCallbacks() {
    widget.deepLinkService.onEmailVerificationSuccess = () {
      DebugLogger.success(
        'E-posta doğrulama başarılı - UI yönlendirme',
        tag: 'MAIN',
      );

      // Ana thread'de navigation yap
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && navigatorKey.currentContext != null) {
          Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const EmailVerificationSuccessScreen(),
            ),
            (route) => route.isFirst,
          );
        }
      });
    };

    widget.deepLinkService.onEmailVerificationError = (error) {
      DebugLogger.error('E-posta doğrulama hatası: $error', tag: 'MAIN');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && navigatorKey.currentContext != null) {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text('❌ E-posta doğrulama hatası: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    };
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
          if (mounted && context.mounted) {
            // Context'in hala geçerli olduğunu ve Provider'ın mevcut olduğunu kontrol et
            final waterProvider = Provider.of<WaterProvider>(
              context,
              listen: false,
            );
            waterProvider.refreshData();
            DebugLogger.info('WaterProvider başarıyla yenilendi', tag: 'MAIN');
          }
        } catch (e) {
          // Provider henüz hazır değilse sessizce devam et
          DebugLogger.info(
            'WaterProvider henüz hazır değil, atlanıyor: $e',
            tag: 'MAIN',
          );
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
        Provider<DeepLinkService>.value(value: widget.deepLinkService),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProvider(widget.cloudSyncService),
        ),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ChangeNotifierProxyProvider2<
          UserProvider,
          StatisticsProvider,
          WaterProvider
        >(
          create: (context) => WaterProvider(widget.cloudSyncService),
          update: (context, userProvider, statsProvider, waterProvider) {
            // UserProvider'daki hedef değişikliğini WaterProvider'a aktar
            waterProvider?.updateGoalFromUserProvider(
              userProvider.dailyWaterGoal,
            );

            // Statistics update callback'ini ayarla
            waterProvider?.setStatsUpdateCallback((amount, type, source) {
              statsProvider.updateStatsOnWaterChange(
                amount: amount,
                type: type,
                source: source,
              );
            });

            // UserProvider'ı set et
            waterProvider?.setUserProvider(userProvider);

            // Context'i burada set etme - HomeScreen'de yapılacak

            return waterProvider!;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(
            widget.notificationService,
            widget.cloudSyncService,
          ),
        ),
        ChangeNotifierProvider(create: (_) => BadgeProvider()),
      ],
      child:
          Consumer6<
            AuthProvider,
            UserProvider,
            WaterProvider,
            NotificationProvider,
            StatisticsProvider,
            BadgeProvider
          >(
            builder:
                (
                  context,
                  authProvider,
                  userProvider,
                  waterProvider,
                  notificationProvider,
                  statsProvider,
                  badgeProvider,
                  child,
                ) {
                  // Badge provider'ı diğer provider'lara bağla
                  waterProvider.setBadgeProvider(badgeProvider);
                  authProvider.setBadgeProvider(badgeProvider);

                  // Çıkış yapıldığında diğer provider'ları temizle
                  authProvider.setSignOutCallback(() {
                    userProvider.clearUserData();
                    waterProvider.clearUserData();
                    statsProvider.clearUserData();
                    badgeProvider.reset();
                  });

                  return MaterialApp(
                    title: 'Su Takip',
                    theme: ThemeData(
                      primarySwatch: Colors.blue,
                      useMaterial3: true,
                    ),
                    navigatorKey: navigatorKey,
                    home: const SplashScreen(),
                    routes: {
                      '/login': (context) => const LoginScreen(),
                      '/home': (context) => const HomeScreen(),
                      '/onboarding': (context) =>
                          const AnimatedOnboardingScreen(),
                      '/profile-setup': (context) =>
                          const AnimatedOnboardingScreen(),
                      '/email-verification-success': (context) =>
                          const EmailVerificationSuccessScreen(),
                    },
                    debugShowCheckedModeBanner: false,
                  );
                },
          ),
    );
  }
}
