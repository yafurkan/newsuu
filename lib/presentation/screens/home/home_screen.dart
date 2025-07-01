import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/calculations.dart';
import '../../providers/water_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/water_progress_card.dart';
import '../../widgets/quick_add_buttons.dart';
import '../../widgets/today_intake_list.dart';
import '../statistics/statistics_screen.dart';
import '../notification_settings/notification_settings_screen.dart';
import '../profile/profile_screen.dart';

/// Ana ekran - Dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında günlük hedefi ayarla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialWaterGoal();
    });
  }

  void _setInitialWaterGoal() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final waterProvider = Provider.of<WaterProvider>(context, listen: false);

    // Eğer kullanıcı bilgileri varsa günlük hedefi hesapla
    if (userProvider.weight > 0) {
      double dailyGoal = WaterCalculations.calculateDailyWaterNeed(
        weight: userProvider.weight,
        age: userProvider.age,
        gender: userProvider.gender,
        activityLevel: userProvider.activityLevel,
      );
      waterProvider.updateDailyGoal(dailyGoal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.appName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer2<WaterProvider, UserProvider>(
        builder: (context, waterProvider, userProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hoş geldin mesajı
                Text(
                      userProvider.firstName.isNotEmpty
                          ? 'Merhaba, ${userProvider.firstName}!'
                          : 'Merhaba!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 600))
                    .slideX(begin: -0.3, end: 0),

                const SizedBox(height: AppDimensions.paddingS),

                Text(
                      'Bugün ne kadar su içtin?',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 600),
                    )
                    .slideX(begin: -0.3, end: 0),

                const SizedBox(height: AppDimensions.paddingXL),

                // Su alımı progress kartı
                const WaterProgressCard()
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 600),
                    )
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: AppDimensions.paddingXL),

                // Hızlı ekleme butonları
                Text(
                      AppStrings.quickAdd,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 600),
                    )
                    .slideX(begin: -0.3, end: 0),

                const SizedBox(height: AppDimensions.paddingM),

                const QuickAddButtons()
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 800),
                      duration: const Duration(milliseconds: 600),
                    )
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: AppDimensions.paddingXL),

                // Bugünkü su alımları listesi
                if (waterProvider.todayIntakes.isNotEmpty) ...[
                  Text(
                        AppStrings.todayIntake,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      )
                      .animate()
                      .fadeIn(
                        delay: const Duration(milliseconds: 1000),
                        duration: const Duration(milliseconds: 600),
                      )
                      .slideX(begin: -0.3, end: 0),

                  const SizedBox(height: AppDimensions.paddingM),

                  const TodayIntakeList()
                      .animate()
                      .fadeIn(
                        delay: const Duration(milliseconds: 1200),
                        duration: const Duration(milliseconds: 600),
                      )
                      .slideY(begin: 0.3, end: 0),
                ],

                const SizedBox(height: AppDimensions.paddingXXL),

                // İstatistikler butonu
                SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const StatisticsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bar_chart),
                        label: const Text(
                          AppStrings.statistics,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.textWhite,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingM,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusM,
                            ),
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 1400),
                      duration: const Duration(milliseconds: 600),
                    )
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          );
        },
      ),
    );
  }
}
