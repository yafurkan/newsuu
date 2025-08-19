import 'package:flutter/material.dart';

import '../data/models/statistics_models.dart';

class StatsPerformanceView extends StatelessWidget {
  final PerformanceMetrics performanceMetrics;

  const StatsPerformanceView({super.key, required this.performanceMetrics});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Performance header
        _buildPerformanceHeader(),
        const SizedBox(height: 16),

        // Metrics grid
        _buildMetricsGrid(),
        const SizedBox(height: 16),

        // Goal analysis
        _buildGoalAnalysis(),
        const SizedBox(height: 16),

        // Motivation card
        _buildMotivationCard(),
      ],
    );
  }

  Widget _buildPerformanceHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Aylık Performans Özeti',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderStat(
                'Streak',
                '${performanceMetrics.streakDays} gün',
                Icons.local_fire_department,
              ),
              _buildHeaderStat(
                'Takip',
                '${performanceMetrics.totalDaysTracked} gün',
                Icons.calendar_today,
              ),
              _buildHeaderStat(
                'Rekor',
                '${performanceMetrics.personalBest.toInt()} ml',
                Icons.emoji_events,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return Row(
      children: [
        Expanded(child: _buildProfileCard()),
        const SizedBox(width: 12),
        Expanded(child: _buildGoalCard()),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: const Color(0xFF4CAF50), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Profil Bilgileri',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProfileItem('Yaş', '${performanceMetrics.currentAge}'),
          _buildProfileItem(
            'Kilo',
            '${performanceMetrics.currentWeight.toInt()} kg',
          ),
          _buildProfileItem(
            'Boy',
            '${performanceMetrics.currentHeight.toInt()} cm',
          ),
          _buildProfileItem(
            'Cinsiyet',
            _getGenderLabel(performanceMetrics.currentGender),
          ),
          _buildProfileItem(
            'Aktivite',
            _getActivityLabel(performanceMetrics.currentActivityLevel),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
    final currentGoal = performanceMetrics.currentGoal;
    final idealGoal = performanceMetrics.idealIntakeForProfile;
    final difference = currentGoal - idealGoal;
    final isOptimal = difference.abs() <= 250; // 250ml tolerance

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag,
                color: isOptimal
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF9800),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Hedef Analizi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGoalItem('Mevcut Hedef', '${currentGoal.toInt()} ml'),
          _buildGoalItem('Önerilen', '${idealGoal.toInt()} ml'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOptimal
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : const Color(0xFFFF9800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isOptimal ? Icons.check_circle : Icons.info,
                  color: isOptimal
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF9800),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isOptimal
                        ? 'Hedef optimal!'
                        : difference > 0
                        ? 'Hedef ${difference.toInt()}ml yüksek'
                        : 'Hedef ${(-difference).toInt()}ml düşük',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOptimal
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF9800),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalAnalysis() {
    final currentGoal = performanceMetrics.currentGoal;
    final idealGoal = performanceMetrics.idealIntakeForProfile;
    final percentage = (currentGoal / idealGoal * 100).clamp(0.0, 200.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hedef vs Önerilen',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: percentage / 200, // 200% max for display
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage >= 90 && percentage <= 110
                  ? const Color(0xFF4CAF50)
                  : percentage < 90
                  ? const Color(0xFFFF5722)
                  : const Color(0xFFFF9800),
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Çok Az',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                'Optimal',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                'Çok Fazla',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Hedefiniz önerilen su tüketiminin %${percentage.toInt()}\'i',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationCard() {
    final streakDays = performanceMetrics.streakDays;
    final totalDays = performanceMetrics.totalDaysTracked;

    String message;
    Color cardColor;
    IconData icon;

    if (streakDays >= 30) {
      message =
          'İnanılmaz! 🏆 Bir aydır kesintisiz takip ediyorsunuz. Siz gerçek bir şampiyonsunuz!';
      cardColor = const Color(0xFFFFD700);
      icon = Icons.emoji_events;
    } else if (streakDays >= 14) {
      message =
          'Harika! 💪 İki haftadır mükemmel gidiyorsunuz. Bu momentum\'u koruyun!';
      cardColor = const Color(0xFF4CAF50);
      icon = Icons.trending_up;
    } else if (streakDays >= 7) {
      message =
          'Tebrikler! 🎉 Bir haftadır düzenli takip ediyorsunuz. İyi gidiyorsunuz!';
      cardColor = const Color(0xFF2196F3);
      icon = Icons.celebration;
    } else if (streakDays >= 3) {
      message =
          'Güzel başlangıç! 👍 Birkaç gündür devam ediyorsunuz. Böyle devam!';
      cardColor = const Color(0xFF9C27B0);
      icon = Icons.thumb_up;
    } else {
      message =
          'Hadi başlayalım! 💧 Düzenli su tüketimi alışkanlığı kazanmanın tam zamanı!';
      cardColor = const Color(0xFFFF9800);
      icon = Icons.water_drop;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(icon, color: cardColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: cardColor,
                  ),
                ),
              ),
            ],
          ),
          if (totalDays > 0) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAchievementBadge(
                  'Streak',
                  '$streakDays gün',
                  Icons.local_fire_department,
                  cardColor,
                ),
                const SizedBox(width: 20),
                _buildAchievementBadge(
                  'Toplam',
                  '$totalDays gün',
                  Icons.calendar_today,
                  cardColor,
                ),
                const SizedBox(width: 20),
                _buildAchievementBadge(
                  'Başarı',
                  '%${((streakDays / totalDays) * 100).toInt()}',
                  Icons.star,
                  cardColor,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
        ),
      ],
    );
  }

  String _getGenderLabel(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Erkek';
      case 'female':
        return 'Kadın';
      default:
        return 'Diğer';
    }
  }

  String _getActivityLabel(String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case 'low':
        return 'Düşük';
      case 'moderate':
        return 'Orta';
      case 'high':
        return 'Yüksek';
      case 'very_high':
        return 'Çok Yüksek';
      default:
        return 'Bilinmeyen';
    }
  }
}
