import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/badge_model.dart';
import '../../../core/constants/colors.dart';

class BadgeCard extends StatelessWidget {
  final BadgeModel badge;
  final VoidCallback? onTap;

  const BadgeCard({
    super.key,
    required this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: badge.isUnlocked
                ? [
                    Color(int.parse(badge.colors[0].replaceFirst('#', '0xFF'))),
                    Color(int.parse(badge.colors[1].replaceFirst('#', '0xFF'))),
                  ]
                : [
                    Colors.grey[300]!,
                    Colors.grey[400]!,
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: badge.isUnlocked
                  ? Color(int.parse(badge.colors[0].replaceFirst('#', '0xFF')))
                      .withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Ana içerik
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rozet ikonu
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      _getBadgeIcon(),
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Rozet adı
                  Text(
                    badge.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Nadir seviye
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge.rarityText,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Kilit ikonu (kilitli rozetler için)
            if (!badge.isUnlocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lock,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            
            // Nadir seviye göstergesi
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(int.parse(badge.rarityColor.replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    _getRarityEmoji(),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
            
            // Yeni rozet efekti
            if (badge.isUnlocked && _isRecentlyUnlocked())
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.yellow,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.new_releases,
                      color: Colors.yellow,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate(target: badge.isUnlocked ? 1 : 0)
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

  bool _isRecentlyUnlocked() {
    if (!badge.isUnlocked || badge.unlockedAt == null) return false;
    
    final now = DateTime.now();
    final unlocked = badge.unlockedAt!;
    final difference = now.difference(unlocked);
    
    return difference.inHours < 24; // Son 24 saat içinde açıldıysa
  }
}