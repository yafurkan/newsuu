import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/badge_model.dart';
import '../../../core/constants/colors.dart';

class BadgeAchievementNotification extends StatefulWidget {
  final BadgeModel badge;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const BadgeAchievementNotification({
    super.key,
    required this.badge,
    this.onTap,
    this.onDismiss,
  });

  @override
  State<BadgeAchievementNotification> createState() =>
      _BadgeAchievementNotificationState();
}

class _BadgeAchievementNotificationState
    extends State<BadgeAchievementNotification>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _dismissController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _dismissController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _controller.forward();

    // 5 saniye sonra otomatik kapat
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _dismissController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _dismissController.forward();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dismissController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -100 * _dismissController.value),
          child: Opacity(
            opacity: 1 - _dismissController.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(int.parse(widget.badge.colors[0].replaceFirst('#', '0xFF'))),
                Color(int.parse(widget.badge.colors[1].replaceFirst('#', '0xFF'))),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(int.parse(widget.badge.colors[0].replaceFirst('#', '0xFF')))
                    .withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Rozet ikonu
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getBadgeIcon(),
                      size: 24,
                      color: Colors.white,
                    ),
                    Text(
                      _getRarityEmoji(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ).animate().scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                curve: Curves.elasticOut,
                duration: 1000.ms,
              ).then().shimmer(
                duration: 1500.ms,
                color: Colors.white.withOpacity(0.5),
              ),
              
              const SizedBox(width: 16),
              
              // Rozet bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '🎉 Yeni Rozet!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _dismiss,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.badge.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.badge.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.3),
            ],
          ),
        ),
      ),
    ).animate()
        .slideY(begin: -1.0, curve: Curves.elasticOut, duration: 800.ms)
        .fadeIn();
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
}