import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../presentation/providers/water_provider.dart';
import '../core/utils/app_theme.dart';

class WaterProgressCard extends StatelessWidget {
  const WaterProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, provider, child) {
        final progress = provider.progress;
        final todayTotal = provider.todayIntake;
        final dailyGoal = provider.dailyGoal;
        final remaining = provider.remainingAmount;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.cardDecoration,
          child: Column(
            children: [
              // Başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Günlük İlerleme', style: AppTheme.titleStyle),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: provider.isGoalCompleted
                          ? AppTheme.successColor.withValues(alpha: 0.1)
                          : AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      provider.isGoalCompleted ? 'Tamamlandı!' : 'Devam et',
                      style: TextStyle(
                        color: provider.isGoalCompleted
                            ? AppTheme.successColor
                            : AppTheme.primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Dairesel ilerleme göstergesi
              CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 12.0,
                percent: progress.clamp(0.0, 1.0),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${todayTotal}ml',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${dailyGoal}ml hedefin',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                progressColor: provider.isGoalCompleted
                    ? AppTheme.successColor
                    : AppTheme.primaryBlue,
                backgroundColor: AppTheme.borderColor,
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1200,
              ),

              const SizedBox(height: 30),

              // İstatistikler
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.local_drink,
                    label: 'İçilen',
                    value: '${(todayTotal / 1000).toStringAsFixed(1)}L',
                    color: AppTheme.primaryBlue,
                  ),
                  Container(height: 40, width: 1, color: AppTheme.borderColor),
                  _buildStatItem(
                    icon: Icons.flag,
                    label: 'Hedef',
                    value: '${(dailyGoal / 1000).toStringAsFixed(1)}L',
                    color: AppTheme.accentBlue,
                  ),
                  Container(height: 40, width: 1, color: AppTheme.borderColor),
                  _buildStatItem(
                    icon: Icons.trending_up,
                    label: 'Kalan',
                    value: remaining > 0
                        ? '${(remaining / 1000).toStringAsFixed(1)}L'
                        : '0L',
                    color: remaining > 0
                        ? AppTheme.warningColor
                        : AppTheme.successColor,
                  ),
                ],
              ),

              // Motivasyon mesajı
              if (provider.isGoalCompleted) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.celebration,
                        color: AppTheme.successColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Tebrikler! Günlük hedefinizi tamamladınız! 🎉',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (progress > 0.5) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_up,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Harika gidiyorsun! Hedefe çok yaklaştın! 💪',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
