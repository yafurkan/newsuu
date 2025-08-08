import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E3C72),
              const Color(0xFF2A5298),
              const Color(0xFF3B82F6),
              const Color(0xFF60A5FA),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Animasyonlu Logo
                _buildAnimatedLogo(),
                const SizedBox(height: 40),

                // Gümüş Geçiş Efektli Başlık
                _buildShimmerTitle(),
                const SizedBox(height: 16),

                // Premium Slogan
                _buildAnimatedSlogan(),
                const SizedBox(height: 60),

                // Premium Google Giriş Butonu
                _buildAnimatedGoogleButton(),
                const SizedBox(height: 32),

                // Güvenlik Mesajı
                _buildSecurityMessage(),
                const SizedBox(height: 40),

                // Premium Özellikler
                _buildPremiumFeatures(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Animasyonlu Logo
  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -10 * _floatController.value),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.1),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.blue.shade100.withOpacity(0.8),
                            Colors.blue.shade300.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(70),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 50,
                            spreadRadius: 20,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.water_drop,
                        size: 70,
                        color: Colors.blue.shade700,
                        shadows: [
                          Shadow(
                            color: Colors.white.withOpacity(0.5),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        )
        .animate()
        .fadeIn(duration: 1000.ms)
        .scale(
          begin: const Offset(0.5, 0.5),
          duration: 800.ms,
          curve: Curves.elasticOut,
        );
  }

  // Gümüş Geçiş Efektli Başlık
  Widget _buildShimmerTitle() {
    return AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withOpacity(0.8),
                    Colors.white,
                    Colors.grey.shade300,
                    Colors.white,
                    Colors.white.withOpacity(0.8),
                  ],
                  stops: [
                    0.0,
                    0.2 + (_shimmerController.value * 0.6),
                    0.5 + (_shimmerController.value * 0.3),
                    0.8 + (_shimmerController.value * 0.2),
                    1.0,
                  ],
                ).createShader(bounds);
              },
              child: const Text(
                'Suu',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 3.0,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        )
        .animate()
        .fadeIn(delay: 500.ms, duration: 800.ms)
        .slideY(begin: -0.3, duration: 600.ms, curve: Curves.easeOut);
  }

  // Premium Slogan
  Widget _buildAnimatedSlogan() {
    return Column(
      children: [
        Text(
              'Sağlıklı Yaşamın Dijital Partneri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(delay: 800.ms, duration: 600.ms)
            .slideY(begin: 0.3, duration: 500.ms),
        const SizedBox(height: 8),
        Text(
              'Akıllı takip • Premium deneyim • Sınırsız motivasyon',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            )
            .animate()
            .fadeIn(delay: 1000.ms, duration: 600.ms)
            .slideY(begin: 0.2, duration: 400.ms),
      ],
    );
  }

  // Premium Google Giriş Butonu
  Widget _buildAnimatedGoogleButton() {
    return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: _isLoading ? 1.0 : (1.0 + (_pulseController.value * 0.02)),
              child: Container(
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isLoading
                        ? [Colors.grey.shade400, Colors.grey.shade500]
                        : [Colors.white, Colors.grey.shade50],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      spreadRadius: -5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade600,
                            ),
                          ),
                        )
                      : Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.login,
                            color: Colors.blue,
                            size: 18,
                          ),
                        ),
                  label: Text(
                    _isLoading ? 'Giriş Yapılıyor...' : 'Google ile Giriş Yap',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _isLoading
                          ? Colors.grey.shade600
                          : Colors.grey.shade800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            );
          },
        )
        .animate()
        .fadeIn(delay: 1200.ms, duration: 600.ms)
        .slideY(begin: 0.3, duration: 500.ms)
        .then()
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3));
  }

  // Güvenlik Mesajı
  Widget _buildSecurityMessage() {
    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security,
                color: Colors.white.withOpacity(0.8),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🔒 Verileriniz güvenle saklanır ve sadece size aittir',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 1400.ms, duration: 600.ms)
        .slideY(begin: 0.2, duration: 400.ms);
  }

  // Premium Özellikler
  Widget _buildPremiumFeatures() {
    return Column(
      children: [
        _buildPremiumFeatureRow(
          Icons.emoji_events,
          'Rozet Sistemi',
          'Başarılarınızı kutlayın ve rozetler kazanın! 🏆',
          1600,
        ),
        const SizedBox(height: 16),
        _buildPremiumFeatureRow(
          Icons.cloud_sync,
          'Bulut Senkronizasyonu',
          'Verileriniz tüm cihazlarınızda güvende 📱',
          1800,
        ),
        const SizedBox(height: 16),
        _buildPremiumFeatureRow(
          Icons.notifications_active,
          'Akıllı Bildirimler',
          'Kişiselleştirilmiş hatırlatmalar 🔔',
          2000,
        ),
        const SizedBox(height: 16),
        _buildPremiumFeatureRow(
          Icons.analytics,
          'Detaylı İstatistikler',
          'Gelişiminizi takip edin ve analiz edin 📊',
          2200,
        ),
      ],
    );
  }

  Widget _buildPremiumFeatureRow(
    IconData icon,
    String title,
    String subtitle,
    int delay,
  ) {
    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: delay.ms, duration: 600.ms)
        .slideX(begin: -0.3, duration: 500.ms, curve: Curves.easeOut);
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();

      // Google ile giriş yap
      final success = await authProvider.signInWithGoogle();

      if (success && mounted) {
        // Kullanıcı verilerini yükle
        await userProvider.loadUserData();

        // Başarılı giriş sonrası yönlendirme - mounted kontrolü
        if (mounted) {
          if (userProvider.isFirstTime) {
            // Yeni kullanıcı → Onboarding'e git
            Navigator.of(context).pushReplacementNamed('/onboarding');
          } else {
            // Mevcut kullanıcı → Ana sayfaya git
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Giriş hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
