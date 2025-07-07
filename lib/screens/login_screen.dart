import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo ve Başlık
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.water_drop,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Uygulama Adı
              const Text(
                'Su Takip',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),

              // Slogan
              Text(
                'Sağlıklı yaşam için su takibi',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),

              // Google ile giriş butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Image.asset(
                          'assets/images/google_logo.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.login, color: Colors.white);
                          },
                        ),
                  label: Text(
                    _isLoading ? 'Giriş yapılıyor...' : 'Google ile Giriş Yap',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: Colors.blue.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Açıklama metni
              Text(
                'Verileriniz güvenle saklanır ve sadece size aittir.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Özellikler
              _buildFeatureRow(
                Icons.cloud_sync,
                'Verileriniz bulutta senkronize',
                'Cihaz değiştirseniz bile verileriniz güvende',
              ),
              const SizedBox(height: 16),
              _buildFeatureRow(
                Icons.notifications_active,
                'Hatırlatma bildirimleri',
                'Su içmeyi unutmayın',
              ),
              const SizedBox(height: 16),
              _buildFeatureRow(
                Icons.analytics,
                'Detaylı istatistikler',
                'Su içme alışkanlıklarınızı takip edin',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
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
