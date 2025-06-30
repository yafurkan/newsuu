import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/colors.dart';
import 'core/constants/strings.dart';
import 'data/services/hive_service.dart';
import 'data/services/notification_service.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/water_provider.dart';
import 'presentation/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive servisini başlat
  final hiveService = HiveService();
  await hiveService.initHive();

  // Bildirim servisini başlat
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    SuTakipApp(
      hiveService: hiveService,
      notificationService: notificationService,
    ),
  );
}

class SuTakipApp extends StatelessWidget {
  final HiveService hiveService;
  final NotificationService notificationService;

  const SuTakipApp({
    super.key,
    required this.hiveService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<HiveService>.value(value: hiveService),
        Provider<NotificationService>.value(value: notificationService),
        ChangeNotifierProvider(create: (_) => UserProvider(hiveService)),
        ChangeNotifierProvider(create: (_) => WaterProvider(hiveService)),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(hiveService, notificationService),
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
