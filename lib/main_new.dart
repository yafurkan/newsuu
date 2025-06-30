import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/colors.dart';
import 'core/constants/strings.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/water_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive veritabanını başlat
  await Hive.initFlutter();

  runApp(const SuTakipApp());
}

class SuTakipApp extends StatelessWidget {
  const SuTakipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider()),
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
