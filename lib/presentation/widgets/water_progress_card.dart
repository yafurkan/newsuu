import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/calculations.dart';
import '../providers/water_provider.dart';

/// Su alımı progress gösterici kartı
class WaterProgressCard extends StatelessWidget {
  const WaterProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, waterProvider, child) {
        final progress = waterProvider.progress / 100;
        final currentIntake = waterProvider.todayIntake;
        final dailyGoal = waterProvider.dailyGoal;
        final remaining = waterProvider.remainingAmount;
        final isCompleted = waterProvider.isGoalCompleted;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.accent.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Progress Circle
              CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 12.0,
                percent: progress > 1.0 ? 1.0 : progress,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      WaterCalculations.formatWaterAmount(currentIntake),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isCompleted
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'içildi',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                progressColor: isCompleted
                    ? AppColors.secondary
                    : AppColors.primary,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 800,
              ).animate().scale(
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
              ),

              const SizedBox(height: AppDimensions.paddingL),

              // Günlük hedef bilgisi
              Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Günlük Hedef',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              WaterCalculations.formatWaterAmount(dailyGoal),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 40,
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isCompleted
                                  ? 'Hedef Tamamlandı!'
                                  : 'Kalan Miktar',
                              style: TextStyle(
                                fontSize: 14,
                                color: isCompleted
                                    ? AppColors.secondary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isCompleted
                                  ? '🎉 Tebrikler!'
                                  : WaterCalculations.formatWaterAmount(
                                      remaining,
                                    ),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isCompleted
                                    ? AppColors.secondary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 600),
                  )
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: AppDimensions.paddingM),

              // Progress yüzdesi
              Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingS,
                      horizontal: AppDimensions.paddingM,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.secondary.withOpacity(0.15)
                          : AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                    child: Text(
                      isCompleted
                          ? '${(progress * 100).toStringAsFixed(0)}% - Harika! Hedefinizi aştınız!'
                          : '${(progress * 100).toStringAsFixed(0)}% tamamlandı',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 600),
                  )
                  .slideY(begin: 0.3, end: 0),

              // Motivasyon mesajı
              if (!isCompleted) ...[
                const SizedBox(height: AppDimensions.paddingS),
                Text(
                  WaterCalculations.evaluateIntake(currentIntake, dailyGoal),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ).animate().fadeIn(
                  delay: const Duration(milliseconds: 800),
                  duration: const Duration(milliseconds: 600),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
