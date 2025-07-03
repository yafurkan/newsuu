import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/constants/colors.dart';
import 'core/constants/strings.dart';
import 'data/services/hive_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/firebase_messaging_service.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/water_provider.dart';
import 'presentation/providers/notification_provider.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔥 Background message: ${message.messageId}');
}

// Bildirim izinlerini kontrol et ve iste
Future<void> _checkAndRequestNotificationPermissions() async {
  try {
    print('🔐 Bildirim izinleri kontrol ediliyor...');

    final status = await Permission.notification.status;
    print('📱 Mevcut izin durumu: $status');

    // TECNO telefon sorunu için zorla dialog göster
    if (status.isDenied || status.isGranted) {
      print('🔔 Bildirim izni isteniyor...');
      final result = await Permission.notification.request();
      print('📋 İzin sonucu: $result');

      if (result.isGranted) {
        print('✅ Bildirim izni başarıyla verildi');
      } else if (result.isDenied) {
        print('❌ Bildirim izni reddedildi');
      } else if (result.isPermanentlyDenied) {
        print('🚫 Bildirim izni kalıcı olarak reddedildi - Ayarları açın');
        // Kullanıcıyı ayarlara yönlendir
        await openAppSettings();
      }
    } else if (status.isPermanentlyDenied) {
      print('🚫 Bildirim izni kalıcı olarak reddedilmiş - Ayarları açın');
      await openAppSettings();
    }
  } catch (e) {
    print('❌ Bildirim izni kontrol hatası: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  await Firebase.initializeApp();

  // Background message handler'ı kaydet
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Hive servisini başlat
  final hiveService = HiveService();
  await hiveService.initHive();

  // Bildirim servisini başlat
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Bildirim izinlerini kontrol et ve gerekirse iste
  await _checkAndRequestNotificationPermissions();

  // Firebase Messaging servisini başlat
  final firebaseMessagingService = FirebaseMessagingService();
  await firebaseMessagingService.initialize();

  // Otomatik topic abonelikleri
  await firebaseMessagingService.subscribeToTopic('all_users');
  await firebaseMessagingService.subscribeToTopic('water_reminders');
  await firebaseMessagingService.subscribeToTopic('daily_tips');

  runApp(
    SuTakipApp(
      hiveService: hiveService,
      notificationService: notificationService,
      firebaseMessagingService: firebaseMessagingService,
    ),
  );
}

class SuTakipApp extends StatefulWidget {
  final HiveService hiveService;
  final NotificationService notificationService;
  final FirebaseMessagingService? firebaseMessagingService;

  const SuTakipApp({
    super.key,
    required this.hiveService,
    required this.notificationService,
    this.firebaseMessagingService,
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
      final waterProvider = context.read<WaterProvider>();
      waterProvider.checkDayTransitionOnResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<HiveService>.value(value: widget.hiveService),
        Provider<NotificationService>.value(value: widget.notificationService),
        ChangeNotifierProvider(create: (_) => UserProvider(widget.hiveService)),
        ChangeNotifierProvider(
          create: (_) => WaterProvider(widget.hiveService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(
            widget.hiveService,
            widget.notificationService,
          ),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textWhite,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
