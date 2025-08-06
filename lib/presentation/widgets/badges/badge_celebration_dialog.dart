import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../../data/models/badge_model.dart';
import '../../../data/services/social_share_service.dart';
import '../../../core/constants/colors.dart';

class BadgeCelebrationDialog extends StatefulWidget {
  final BadgeModel badge;
  final String userName;
  final VoidCallback? onContinue;

  const BadgeCelebrationDialog({
    super.key,
    required this.badge,
    required this.userName,
    this.onContinue,
  });

  @override
  State<BadgeCelebrationDialog> createState() => _BadgeCelebrationDialogState();
}

class _BadgeCelebrationDialogState extends State<BadgeCelebrationDialog>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final SocialShareService _socialShareService = SocialShareService();

  @override
  void initState() {
    super.initState();
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Animasyonları başlat
    _startCelebration();
  }

  void _startCelebration() async {
    // Konfeti başlat
    _confettiController.play();
    
    // Rozet animasyonunu başlat
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _scaleController.forward();
    }
    
    // Bounce animasyonunu başlat
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      _bounceController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Geri tuşunu devre dışı bırak
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Konfeti
            Positioned(
              top: 0,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 1.5708, // Aşağı doğru (π/2)
                emissionFrequency: 0.3,
                numberOfParticles: 15,
                maxBlastForce: 100,
                minBlastForce: 80,
                gravity: 0.3,
                colors: [
                  Color(int.parse(widget.badge.colors[0].replaceFirst('#', '0xFF'))),
                  Color(int.parse(widget.badge.colors[1].replaceFirst('#', '0xFF'))),
                  AppColors.secondary,
                  AppColors.accent,
                  Colors.yellow,
                  Colors.orange,
                ],
              ),
            ),
            
            // Sol konfeti
            Positioned(
              left: 50,
              top: 100,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 0.7854, // Sağ alt (π/4)
                emissionFrequency: 0.2,
                numberOfParticles: 10,
                maxBlastForce: 80,
                minBlastForce: 60,
                gravity: 0.2,
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                  Colors.pink,
                  Colors.purple,
                ],
              ),
            ),
            
            // Sağ konfeti
            Positioned(
              right: 50,
              top: 100,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 2.3562, // Sol alt (3π/4)
                emissionFrequency: 0.2,
                numberOfParticles: 10,
                maxBlastForce: 80,
                minBlastForce: 60,
                gravity: 0.2,
                colors: [
                  AppColors.accent,
                  Colors.green,
                  Colors.cyan,
                  Colors.blue,
                ],
              ),
            ),

            // Ana dialog
            RepaintBoundary(
              key: _repaintBoundaryKey,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(int.parse(widget.badge.colors[0].replaceFirst('#', '0xFF'))),
                      Color(int.parse(widget.badge.colors[1].replaceFirst('#', '0xFF'))),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Color(int.parse(widget.badge.colors[0].replaceFirst('#', '0xFF')))
                          .withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tebrikler başlığı
                    Text(
                      '🎉 TEBRİKLER! 🎉',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.3),
                    
                    const SizedBox(height: 20),
                    
                    // Rozet ikonu (animasyonlu)
                    AnimatedBuilder(
                      animation: _scaleController,
                      builder: (context, child) {
                        return AnimatedBuilder(
                          animation: _bounceController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleController.value * (1.0 + _bounceController.value * 0.1),
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(60),
                                  border: Border.all(color: Colors.white, width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
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
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Rozet adı
                    Text(
                      widget.badge.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
                    
                    const SizedBox(height: 8),
                    
                    // Nadir seviye
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_getRarityEmoji()} ${widget.badge.rarityText} Rozet',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms).scale(),
                    
                    const SizedBox(height: 16),
                    
                    // Açıklama
                    Text(
                      widget.badge.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 1000.ms),
                    
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
                    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3),
                    
                    const SizedBox(height: 24),
                    
                    // Butonlar
                    Row(
                      children: [
                        // Paylaş butonu
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _shareBadge,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.white, width: 1),
                              ),
                            ),
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text(
                              'Paylaş',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Devam et butonu
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onContinue?.call();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(int.parse(
                                  widget.badge.colors[0].replaceFirst('#', '0xFF'))),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.arrow_forward, size: 18),
                            label: const Text(
                              'Devam Et',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 1400.ms).slideY(begin: 0.5),
                  ],
                ),
              ),
            ),
          ],
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