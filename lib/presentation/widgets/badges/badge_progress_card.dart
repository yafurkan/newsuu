import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../data/models/badge_model.dart';
import '../../../core/constants/colors.dart';

class BadgeProgressCard extends StatelessWidget {
  final BadgeModel badge;
  final double currentProgress;
  final String progressText;
  final VoidCallback? onTap;

  const BadgeProgressCard({
    super.key,
    required this.badge,
    required this.currentProgress,
    required this.progressText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercentage = (currentProgress / badge.requiredValue).clamp(0.0, 1.0);
    final isCompleted = progressPercentage >= 1.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isCompleted
                ? [
                    Color(int.parse(badge.colors[0].replaceFirst('#', '0xFF'))),
                    Color(int.parse(badge.colors[1].replaceFirst('#', '0xFF'))),
                  ]
                : [
                    Colors.grey[100]!,
                    Colors.grey[200]!,
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isCompleted
                  ? Color(int.parse(badge.colors[0].replaceFirst('#', '0xFF')))
                      .withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst kısım - Rozet bilgileri
            Row(
              children: [
                // Rozet ikonu
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? Colors.white.withOpacity(0.2)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getBadgeIcon(),
                        size: 20,
                        color: isCompleted ? Colors.white : AppColors.primary,
                      ),
                      Text(
                        _getRarityEmoji(),
                        style: const TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Rozet bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              badge.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isCompleted ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'TAMAMLANDI',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badge.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isCompleted 
                              ? Colors.white.withOpacity(0.9)
                              : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // İlerleme çubuğu
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      progressText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isCompleted ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${(progressPercentage * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  lineHeight: 8,
                  percent: progressPercentage,
                  backgroundColor: isCompleted 
                      ? Colors.white.withOpacity(0.3)
                      : AppColors.border,
                  progressColor: isCompleted
                      ? Colors.white
                      : Color(int.parse(badge.colors[0].replaceFirst('#', '0xFF'))),
                  barRadius: const Radius.circular(4),
                  animation: true,
                  animationDuration: 1000,
                ),
              ],
            ),
            
            // Alt kısım - Hedef bilgisi
            if (!isCompleted) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getTargetText(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate(target: isCompleted ? 1 : 0)
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5))
        .then()
        .shake(hz: 2, curve: Curves.easeInOut);
  }

  IconData _getBadgeIcon() {
    switch (badge.category) {
      case 'water_drinking':
        return Icons.water_drop;
      case 'quick_add':
        return Icons.touch_app;
      case 'consistency':
        return Icons.trending_up;
      case 'special':
        return Icons.star;
      default:
        return Icons.emoji_events;
    }
  }

  String _getRarityEmoji() {
    switch (badge.rarity) {
      case 1:
        return '🥉';
      case 2:
        return '🥈';
      case 3:
        return '🥇';
      case 4:
        return '💎';
      default:
        return '🏆';
    }
  }

  String _getTargetText() {
    switch (badge.requiredAction) {
      case 'first_water_add':
        return 'İlk su kaydınızı yapın';
      case 'daily_goal_complete':
        return 'Günlük hedefinizi tamamlayın';
      case 'daily_amount_3000':
        return 'Günde 3 litre su için';
      case 'daily_amount_5000':
        return 'Günde 5 litre su için';
      case 'consecutive_days':
        return '${badge.requiredValue} gün üst üste için';
      case 'button_250ml_first':
        return '250ml butonunu kullanın';
      case 'button_500ml_10_times':
        return '500ml butonunu 10 kez kullanın';
      case 'button_750ml_5_times':
        return '750ml butonunu 5 kez kullanın';
      case 'button_1000ml_first':
        return '1000ml butonunu kullanın';
      case 'all_buttons_used':
        return 'Tüm butonları kullanın';
      default:
        return 'Hedefe ulaşın';
    }
  }
}
