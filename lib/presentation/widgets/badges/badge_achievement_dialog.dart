import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/badge_model.dart';
import '../../../data/services/social_share_service.dart';
import '../../../core/constants/colors.dart';

class BadgeAchievementDialog extends StatefulWidget {
  final BadgeModel badge;
  final String userName;

  const BadgeAchievementDialog({
    super.key,
    required this.badge,
    required this.userName,
  });

  @override
  State<BadgeAchievementDialog> createState() => _BadgeAchievementDialogState();
}

class _BadgeAchievementDialogState extends State<BadgeAchievementDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final SocialShareService _socialShareService = SocialShareService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: RepaintBoundary(
        key: _repaintBoundaryKey,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.badge.isUnlocked
                  ? [
                      Color(int.parse(widget.badge.colors[0].replaceFirst('#', '0xFF'))),
                      Color(int.parse(widget.badge.colors[1].replaceFirst('#', '0xFF'))),
                    ]
                  : [
                      Colors.grey[400]!,
                      Colors.grey[600]!,
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.badge.isUnlocked
                    ? Color(int.parse(widget.badge.colors[0].replaceFirst('#', '0xFF')))
                        .withOpacity(0.4)
                    : Colors.grey.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              if (widget.badge.isUnlocked)
                Text(
                  '🎉 Tebrikler! 🎉',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn().slideY(begin: -0.3),
              
              const SizedBox(height: 16),
              
              // Rozet ikonu ve bilgileri
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getBadgeIcon(),
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRarityEmoji(),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ).animate().scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                curve: Curves.elasticOut,
                duration: 1500.ms,
              ).then().shimmer(
                duration: 2000.ms,
                color: Colors.white.withOpacity(0.5),
              ),
              
              const SizedBox(height: 20),
              
              // Rozet adı
              Text(
                widget.badge.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
              
              const SizedBox(height: 8),
              
              // Nadir seviye
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.badge.rarityText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),
              
              const SizedBox(height: 16),
              
              // Açıklama
              Text(
                widget.badge.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 700.ms),
              
              const SizedBox(height: 16),
              
              // Eğlenceli bilgi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Bilgi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.badge.funFact,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3),
              
              const SizedBox(height: 24),
              
              // Butonlar
              Row(
                children: [
                  // Kapat butonu
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Kapat',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Paylaş butonu (sadece açık rozetler için)
                  if (widget.badge.isUnlocked)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _shareBadge,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(int.parse(
                              widget.badge.colors[0].replaceFirst('#', '0xFF'))),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.share, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Paylaş',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.5),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBadgeIcon() {
    switch (widget.badge.category) {
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
    switch (widget.badge.rarity) {
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

  Future<void> _shareBadge() async {
    try {
      await _socialShareService.shareBadgeAchievement(
        badge: widget.badge,
        userName: widget.userName,
        repaintBoundaryKey: _repaintBoundaryKey,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paylaşım hatası: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}