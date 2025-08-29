import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/user_provider.dart';
import '../presentation/providers/water_provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/widgets/water_progress_card.dart';
import '../presentation/widgets/quick_add_buttons.dart';
import '../presentation/widgets/today_intake_list.dart';
import '../presentation/widgets/weather_time_widget.dart';
import '../presentation/widgets/common/email_verification_banner.dart';
import '../presentation/widgets/common/email_verification_guard.dart';
import '../presentation/widgets/common/location_permission_banner.dart';
import '../core/utils/app_theme.dart';
import 'profile_screen.dart';
import 'statistics_screen.dart';
import 'badges_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shimmerController.repeat();

    // Verileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WaterProvider>().refreshData();
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Context tamamen hazır olduğunda set et
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // WaterProvider'a context'i set et (rozet bildirimleri için)
        // Bu context MaterialApp içinde olduğu için Overlay'e erişebilir
        final waterProvider = context.read<WaterProvider>();
        waterProvider.setContext(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.1),
              Colors.white,
              AppTheme.primaryBlue.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer3<UserProvider, WaterProvider, AuthProvider>(
            builder: (context, userProvider, waterProvider, authProvider, child) {
              if (userProvider.isLoading || waterProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Header
                    _buildPremiumHeader(),

                    // Konum izni banner'ı
                    LocationPermissionBanner(
                      onPermissionGranted: () {
                        // Hava durumu widget'ını yenile
                        setState(() {});
                      },
                    ),

                    // Hava durumu ve saat widget'ı
                    WeatherTimeWidget(
                      userName: userProvider.firstName.isNotEmpty
                          ? userProvider.firstName
                          : 'Kullanıcı',
                    ),

                    const SizedBox(height: 8),

                    // E-posta doğrulama banner'ı
                    const EmailVerificationBanner(),

                    const SizedBox(height: 16),

                    // Su ilerleme kartı
                    const WaterProgressCard(),
                    const SizedBox(height: 16),

                    // Hızlı ekleme butonları (E-posta doğrulama guard'ı ile)
                    EmailVerificationGuard(
                      customMessage:
                          'Su ekleyebilmek için lütfen e-posta adresinizi doğrulayın.',
                      child: const QuickAddButtons(),
                    ),
                    const SizedBox(height: 16),

                    // Bugünkü alım listesi
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Bugünkü Su Alımları',
                        style: AppTheme.titleStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ).animate().fadeIn(
                      delay: const Duration(milliseconds: 1000),
                    ),

                    const SizedBox(height: 8),
                    const TodayIntakeList(),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Logo ve başlık
          Expanded(
            child: Row(
              children: [
                // Animasyonlu logo
                Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryBlue, Colors.blue.shade300],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: 28,
                      ),
                    )
                    .animate()
                    .scale(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                    )
                    .then()
                    .shimmer(
                      duration: const Duration(milliseconds: 1500),
                      color: Colors.blue.shade200,
                    ),

                const SizedBox(width: 16),

                // Shimmer başlık
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppTheme.primaryBlue,
                            Colors.blue.shade300,
                            AppTheme.primaryBlue,
                          ],
                          stops: [
                            _shimmerController.value - 0.3,
                            _shimmerController.value,
                            _shimmerController.value + 0.3,
                          ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
                        ).createShader(bounds);
                      },
                      child: Text(
                        'Suu',
                        style: AppTheme.titleStyle.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
              ],
            ),
          ),

          // Action buttons
          Row(
            children: [
              _buildActionButton(
                icon: Icons.bar_chart,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatisticsScreen(),
                    ),
                  );
                },
                color: Colors.green.shade600,
              ),

              const SizedBox(width: 12),

              _buildActionButton(
                icon: Icons.emoji_events,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BadgesScreen(),
                    ),
                  );
                },
                color: Colors.orange.shade600,
              ),

              const SizedBox(width: 12),

              _buildActionButton(
                icon: Icons.person,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                color: Colors.purple.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    ).animate().scale(
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
