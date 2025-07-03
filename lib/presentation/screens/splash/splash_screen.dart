import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/assets.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import '../profile_setup/profile_setup_screen.dart';

/// Uygulama açılış ekranı
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // 3 saniye bekle (animasyonlar tamamlansın)
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // Bildirim izni kontrol et
      await _checkNotificationPermission();

      // Auth provider'ını al
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Kullanıcı giriş yapmış mı kontrol et
      if (!authProvider.isSignedIn) {
        // Giriş yapılmamış - Login ekranına git
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      // Kullanıcı profili var mı kontrol et
      if (authProvider.userProfile == null ||
          authProvider.userProfile!.firstName.isEmpty) {
        // Profil tamamlanmamış - Profile Setup'a git
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
        );
      } else {
        // Her şey tamam - Ana ekrana git
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  /// Bildirim izni kontrol et ve gerekirse iste
  Future<void> _checkNotificationPermission() async {
    final permission = Permission.notification;
    final status = await permission.status;

    print('🔐 Splash: Bildirim izin durumu: $status');

    if (status.isDenied || status.isLimited) {
      print('🔔 Splash: Bildirim izni isteniyor...');
      await _showPermissionDialog();
    } else if (status.isPermanentlyDenied) {
      print('⚠️ Splash: Bildirim izni kalıcı olarak reddedilmiş');
      await _showSettingsDialog();
    }
  }

  /// İzin dialog'u göster
  Future<void> _showPermissionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🔔 Bildirim İzni'),
          content: const Text(
            'Su içme hatırlatmaları ve önemli bildirimler için bildirim izni gereklidir.\n\nLütfen "İzin Ver" seçeneğini seçin.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('İzin Ver'),
              onPressed: () async {
                Navigator.of(context).pop();
                final result = await Permission.notification.request();
                print('🔔 Splash: İzin sonucu: $result');
              },
            ),
          ],
        );
      },
    );
  }

  /// Ayarlar dialog'u göster
  Future<void> _showSettingsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⚙️ Ayarlar'),
          content: const Text(
            'Bildirim izni ayarlardan manuel olarak açılmalıdır.\n\nAyarlar > Uygulamalar > Suu > İzinler > Bildirimler',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Ayarları Aç'),
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animasyonu
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.textWhite,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusXXL,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black26,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusXXL,
                    ),
                    child: Image.asset(
                      AppAssets.appLogo,
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Logo yoksa icon göster
                        return const Icon(
                          Icons.water_drop_rounded,
                          size: 60,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  ),
                )
                .animate()
                .scale(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                )
                .then(delay: const Duration(milliseconds: 200))
                .shimmer(
                  duration: const Duration(milliseconds: 1000),
                  color: AppColors.textWhite.withOpacity(0.3),
                ),

            const SizedBox(height: AppDimensions.paddingXXL),

            // Uygulama adı
            Text(
                  AppStrings.appName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                    letterSpacing: 1.2,
                  ),
                )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 600),
                )
                .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

            const SizedBox(height: AppDimensions.paddingM),

            // Alt yazı
            Text(
                  AppStrings.appTagline,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textWhite.withOpacity(0.9),
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(
                  delay: const Duration(milliseconds: 800),
                  duration: const Duration(milliseconds: 600),
                )
                .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

            const SizedBox(height: AppDimensions.paddingXXXL),

            // Yükleme animasyonu
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.textWhite.withOpacity(0.8),
              ),
            ).animate().fadeIn(
              delay: const Duration(milliseconds: 1200),
              duration: const Duration(milliseconds: 400),
            ),
          ],
        ),
      ),
    );
  }
}
