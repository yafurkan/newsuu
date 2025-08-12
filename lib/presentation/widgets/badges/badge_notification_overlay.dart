import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/badge_model.dart';

class BadgeNotificationOverlay extends StatefulWidget {
  final BadgeModel badge;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const BadgeNotificationOverlay({
    super.key,
    required this.badge,
    this.onTap,
    this.onDismiss,
  });

  @override
  State<BadgeNotificationOverlay> createState() => _BadgeNotificationOverlayState();
}

class _BadgeNotificationOverlayState extends State<BadgeNotificationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _dismissController;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _dismissController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Animasyonları başlat
    _slideController.forward();
    _pulseController.repeat(reverse: true);

    // 4 saniye sonra otomatik kapat
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
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
          offset: Offset(0, -80 * _dismissController.value),
          child: Opacity(
            opacity: 1 - _dismissController.value,
            child: child,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _slideController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -100 * (1 - _slideController.value)),
            child: child,
          );
        },
        child: GestureDetector(
          onTap: () {
            widget.onTap?.call();
            _dismiss();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(int.parse(widget.badge.colors[0].replaceFirst('#', '0xFF'))),
                  Color(int.parse(widget.badge.colors[1].replaceFirst('#', '0xFF'))),
                  Color(int.parse(widget.badge.colors[0].replaceFirst('#', '0xFF'))).withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(int.parse(widget.badge.colors[0].replaceFirst('#', '0xFF')))
                      .withValues(alpha: 0.6),
                  blurRadius: 25,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: -5,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Animasyonlu rozet ikonu
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.1),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white, width: 2),
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
                      ),
                    );
                  },
                ),
                
                const SizedBox(width: 16),
                
                // Rozet bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '🎉 YENİ ROZET KAZANDIN!',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    offset: const Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _dismiss,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
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
                        widget.badge.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              offset: const Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.3),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                        ),
                        child: Text(
                          '👆 TIKLA VE KUTLA! 🎊',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: const Offset(0.5, 0.5),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.8, 0.8)),
                    ],
                  ),
                ),
                
                // Tap indicator - Güçlendirilmiş
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.2),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.4),
                              Colors.white.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.3),
                              blurRadius: 10 + (_pulseController.value * 5),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.touch_app,
                          size: 24,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
        .slideY(begin: -1.2, curve: Curves.elasticOut, duration: 1000.ms)
        .fadeIn(duration: 600.ms)
        .then()
        .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.3))
        .then()
        .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.02, 1.02), duration: 500.ms)
        .then()
        .scale(begin: const Offset(1.02, 1.02), end: const Offset(1.0, 1.0), duration: 500.ms);
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
