import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/user_provider.dart';
import '../presentation/providers/water_provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/widgets/water_progress_card.dart';
import '../presentation/widgets/quick_add_buttons.dart';
import '../presentation/widgets/today_intake_list.dart';
import '../presentation/widgets/common/email_verification_banner.dart';
import '../presentation/widgets/common/email_verification_guard.dart';
import 'profile_screen.dart';
import 'statistics_screen.dart';
import 'badges_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Verileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WaterProvider>().refreshData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Su Takip'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BadgesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer3<UserProvider, WaterProvider, AuthProvider>(
        builder: (context, userProvider, waterProvider, authProvider, child) {
          if (userProvider.isLoading || waterProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // E-posta doğrulama banner'ı
                const EmailVerificationBanner(),
                
                // Hoş geldin mesajı
                Text(
                  'Merhaba, ${userProvider.firstName}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Su ilerleme kartı
                const WaterProgressCard(),
                const SizedBox(height: 16),

                // Hızlı ekleme butonları (E-posta doğrulama guard'ı ile)
                EmailVerificationGuard(
                  customMessage: 'Su ekleyebilmek için lütfen e-posta adresinizi doğrulayın.',
                  child: const QuickAddButtons(),
                ),
                const SizedBox(height: 16),

                // Bugünkü alım listesi
                const Text(
                  'Bugünkü Su Alımları',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const TodayIntakeList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
