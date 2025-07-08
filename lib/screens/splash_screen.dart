import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/app_theme.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    // Animasyonu başlat
    _animationController.forward();

    // 3 saniye bekle
    await Future.delayed(const Duration(seconds: 3));

    // Auth durumunu kontrol et ve yönlendir
    if (mounted) {
      _checkAuthAndNavigate();
    }
  }

  void _checkAuthAndNavigate() async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    if (authProvider.isSignedIn) {
      // Kullanıcı giriş yapmış
      try {
        await userProvider.loadUserData();

        if (mounted) {
          if (userProvider.isFirstTime) {
            // İlk kez giriş yapan kullanıcı → Onboarding
            Navigator.of(context).pushReplacementNamed('/onboarding');
          } else {
            // Mevcut kullanıcı → Ana sayfa
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
      } catch (e) {
        // Kullanıcı verisi yüklenemedi → Onboarding'e gönder
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/onboarding');
        }
      }
    } else {
      // Kullanıcı giriş yapmamış → Login ekranı
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Auth state değiştiğinde navigation yap
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                final currentRoute = ModalRoute.of(context)?.settings.name;

                if (!authProvider.isSignedIn && currentRoute != '/login') {
                  // Çıkış yapıldıysa login ekranına yönlendir
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              }
            });

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animasyonu
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.water_drop,
                              size: 60,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Uygulama adı
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'Su Takip',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Alt başlık
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'Sağlıklı yaşamın anahtarı',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Yükleniyor animasyonu
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
