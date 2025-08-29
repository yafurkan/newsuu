import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../providers/water_provider.dart';
import '../../providers/user_provider.dart';

/// Rozetler ekranı - Başarılar ve ödüller
class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        title: const Text(
          '🏆 Rozetler',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Consumer2<WaterProvider, UserProvider>(
        builder: (context, waterProvider, userProvider, child) {
          final badges = _getBadges(waterProvider, userProvider);
          final earnedBadges = badges.where((badge) => badge.isEarned).toList();
          final lockedBadges = badges.where((badge) => !badge.isEarned).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İstatistik kartları
                _buildStatsCards(earnedBadges.length, badges.length),
                
                const SizedBox(height: AppDimensions.paddingXL),

                // Kazanılan rozetler
                if (earnedBadges.isNotEmpty) ...[
                  Text(
                    '✨ Kazanılan Rozetler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.3),
                  
                  const SizedBox(height: AppDimensions.paddingM),
                  
                  _buildBadgeGrid(earnedBadges, true),
                  
                  const SizedBox(height: AppDimensions.paddingXL),
                ],

                // Kilitli rozetler
                if (lockedBadges.isNotEmpty) ...[
                  Text(
                    '🔒 Kilitli Rozetler',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: -0.3),
                  
                  const SizedBox(height: AppDimensions.paddingM),
                  
                  _buildBadgeGrid(lockedBadges, false),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(int earned, int total) {
    final percentage = total > 0 ? (earned / total * 100).toInt() : 0;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '🏆',
            'Kazanılan',
            '$earned',
            AppColors.success,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingM),
        Expanded(
          child: _buildStatCard(
            '📊',
            'Toplam',
            '$total',
            AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingM),
        Expanded(
          child: _buildStatCard(
            '📈',
            'Tamamlama',
            '%$percentage',
            AppColors.secondary,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3);
  }

  Widget _buildStatCard(String icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeGrid(List<Badge> badges, bool isEarned) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: AppDimensions.paddingM,
        mainAxisSpacing: AppDimensions.paddingM,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        return _buildBadgeCard(badges[index], isEarned)
            .animate(delay: Duration(milliseconds: 100 * index))
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.3);
      },
    );
  }

  Widget _buildBadgeCard(Badge badge, bool isEarned) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(badge),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isEarned 
                ? AppColors.success.withOpacity(0.3)
                : AppColors.border.withOpacity(0.3),
            width: isEarned ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  badge.icon,
                  style: TextStyle(
                    fontSize: 40,
                    color: isEarned ? null : Colors.grey.withOpacity(0.5),
                  ),
                ),
                if (!isEarned)
                  Icon(
                    Icons.lock,
                    color: Colors.grey.withOpacity(0.7),
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isEarned ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (badge.isEarned && badge.earnedDate != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatDate(badge.earnedDate!),
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(Badge badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              badge.icon,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              badge.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              badge.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              badge.requirement,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            if (badge.isEarned && badge.earnedDate != null) ...[
              const SizedBox(height: AppDimensions.paddingM),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  '✅ ${_formatDate(badge.earnedDate!)} tarihinde kazanıldı',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tamam',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  List<Badge> _getBadges(WaterProvider waterProvider, UserProvider userProvider) {
    final totalIntakes = waterProvider.allIntakes.length;
    final totalAmount = waterProvider.allIntakes.fold<double>(
      0.0, (sum, intake) => sum + intake.amount,
    );
    final streakDays = waterProvider.getCurrentStreak();
    final achievedDays = _getAchievedDaysCount(waterProvider, userProvider);

    return [
      Badge(
        id: 'first_drop',
        icon: '💧',
        title: 'İlk Damla',
        description: 'İlk su alımını kaydet',
        requirement: '1 su alımı kaydet',
        isEarned: totalIntakes >= 1,
        earnedDate: totalIntakes >= 1 ? waterProvider.allIntakes.first.timestamp : null,
      ),
      Badge(
        id: 'hydration_hero',
        icon: '🦸‍♂️',
        title: 'Hidrasyon Kahramanı',
        description: 'Günlük hedefini 7 gün üst üste tut',
        requirement: '7 gün üst üste hedef tut',
        isEarned: streakDays >= 7,
        earnedDate: streakDays >= 7 ? DateTime.now().subtract(Duration(days: 7 - streakDays)) : null,
      ),
      Badge(
        id: 'water_warrior',
        icon: '⚔️',
        title: 'Su Savaşçısı',
        description: '30 gün üst üste hedef tut',
        requirement: '30 gün üst üste hedef tut',
        isEarned: streakDays >= 30,
        earnedDate: streakDays >= 30 ? DateTime.now().subtract(Duration(days: 30 - streakDays)) : null,
      ),
      Badge(
        id: 'ocean_master',
        icon: '🌊',
        title: 'Okyanus Ustası',
        description: 'Toplam 100 litre su iç',
        requirement: '100,000 ml toplam su alımı',
        isEarned: totalAmount >= 100000,
        earnedDate: totalAmount >= 100000 ? DateTime.now() : null,
      ),
      Badge(
        id: 'consistency_king',
        icon: '👑',
        title: 'Tutarlılık Kralı',
        description: '30 günde 25 gün hedef tut',
        requirement: '30 günde 25 gün hedef tut',
        isEarned: achievedDays >= 25,
        earnedDate: achievedDays >= 25 ? DateTime.now() : null,
      ),
      Badge(
        id: 'early_bird',
        icon: '🌅',
        title: 'Erken Kuş',
        description: 'Sabah 8\'den önce su iç',
        requirement: 'Sabah 8:00\'den önce su alımı kaydet',
        isEarned: _hasEarlyMorningIntake(waterProvider),
        earnedDate: _hasEarlyMorningIntake(waterProvider) ? DateTime.now() : null,
      ),
      Badge(
        id: 'night_owl',
        icon: '🦉',
        title: 'Gece Kuşu',
        description: 'Gece 22\'den sonra su iç',
        requirement: 'Gece 22:00\'den sonra su alımı kaydet',
        isEarned: _hasLateNightIntake(waterProvider),
        earnedDate: _hasLateNightIntake(waterProvider) ? DateTime.now() : null,
      ),
      Badge(
        id: 'perfect_week',
        icon: '⭐',
        title: 'Mükemmel Hafta',
        description: '7 gün boyunca her gün hedef tut',
        requirement: '7 gün üst üste %100 hedef tut',
        isEarned: streakDays >= 7,
        earnedDate: streakDays >= 7 ? DateTime.now().subtract(Duration(days: 7)) : null,
      ),
    ];
  }

  int _getAchievedDaysCount(WaterProvider waterProvider, UserProvider userProvider) {
    int count = 0;
    for (int i = 0; i < 30; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dayIntakes = waterProvider.getIntakesForDate(date);
      final totalAmount = dayIntakes.fold<double>(0.0, (sum, intake) => sum + intake.amount);
      if (totalAmount >= userProvider.dailyWaterGoal) count++;
    }
    return count;
  }

  bool _hasEarlyMorningIntake(WaterProvider waterProvider) {
    return waterProvider.allIntakes.any((intake) => intake.timestamp.hour < 8);
  }

  bool _hasLateNightIntake(WaterProvider waterProvider) {
    return waterProvider.allIntakes.any((intake) => intake.timestamp.hour >= 22);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class Badge {
  final String id;
  final String icon;
  final String title;
  final String description;
  final String requirement;
  final bool isEarned;
  final DateTime? earnedDate;

  Badge({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.requirement,
    required this.isEarned,
    this.earnedDate,
  });
}