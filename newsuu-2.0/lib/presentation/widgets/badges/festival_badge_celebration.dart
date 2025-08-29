import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../../data/models/badge_model.dart';
import '../../../data/services/social_share_service.dart';

class FestivalBadgeCelebration extends StatefulWidget {
  final BadgeModel badge;
  final String userName;
  final VoidCallback? onContinue;

  const FestivalBadgeCelebration({
    super.key,
    required this.badge,
    required this.userName,
    this.onContinue,
  });

  @override
  State<FestivalBadgeCelebration> createState() =>
      _FestivalBadgeCelebrationState();
}

class _FestivalBadgeCelebrationState extends State<FestivalBadgeCelebration>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late ConfettiController _leftConfettiController;
  late ConfettiController _rightConfettiController;
  late ConfettiController _centerConfettiController;

  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late AnimationController _rotateController;
  late AnimationController _sparkleController;
  late AnimationController _textController;

  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final SocialShareService _socialShareService = SocialShareService();

  @override
  void initState() {
    super.initState();

    // Konfeti controller'ları
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
    _leftConfettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _rightConfettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _centerConfettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    // Animasyon controller'ları
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Festival kutlamasını başlat
    _startFestivalCelebration();
  }

  void _startFestivalCelebration() async {
    // 1. Konfeti patlaması - çoklu yönlerden
    _confettiController.play();
    _leftConfettiController.play();
    _rightConfettiController.play();

    // 2. Rozet animasyonu - büyük giriş
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _scaleController.forward();
    }

    // 3. Döndürme animasyonu
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      _rotateController.forward();
    }

    // 4. Merkez konfeti patlaması
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      _centerConfettiController.play();
    }

    // 5. Bounce animasyonu
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      _bounceController.repeat(reverse: true);
    }

    // 6. Sparkle efekti
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      _sparkleController.repeat();
    }

    // 7. Text animasyonu
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      _textController.forward();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _leftConfettiController.dispose();
    _rightConfettiController.dispose();
    _centerConfettiController.dispose();
    _scaleController.dispose();
    _bounceController.dispose();
    _rotateController.dispose();
    _sparkleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                Color(
                  int.parse(widget.badge.colors[0].replaceFirst('#', '0xFF')),
                ).withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Konfeti efektleri - çoklu yönlü
              ..._buildConfettiEffects(),

              // Ana kutlama dialog'u
              RepaintBoundary(
                key: _repaintBoundaryKey,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(
                          int.parse(
                            widget.badge.colors[0].replaceFirst('#', '0xFF'),
                          ),
                        ),
                        Color(
                          int.parse(
                            widget.badge.colors[1].replaceFirst('#', '0xFF'),
                          ),
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Color(
                          int.parse(
                            widget.badge.colors[0].replaceFirst('#', '0xFF'),
                          ),
                        ).withValues(alpha: 0.6),
                        blurRadius: 30,
                        spreadRadius: 10,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Festival başlığı
                        AnimatedBuilder(
                          animation: _textController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_textController.value * 0.1),
                              child:
                                  Text(
                                        '🎊 MUHTEŞEM! 🎊',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              offset: Offset(2, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                      .animate()
                                      .fadeIn(delay: 100.ms)
                                      .slideY(begin: -0.5)
                                      .then()
                                      .shimmer(
                                        duration: 2000.ms,
                                        color: Colors.white,
                                      ),
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        // Motivasyonel alt başlık
                        Text(
                          _getMotivationalSubtitle(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),

                        const SizedBox(height: 24),

                        // Animasyonlu rozet ikonu
                        _buildAnimatedBadgeIcon(),

                        const SizedBox(height: 24),

                        // Rozet adı ve seviye
                        AnimatedBuilder(
                          animation: _textController,
                          builder: (context, child) {
                            return Column(
                              children: [
                                Text(
                                  widget.badge.name,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    '${_getRarityEmoji()} ${widget.badge.rarityText} Seviye',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ).animate().fadeIn(delay: 800.ms).scale(),

                        const SizedBox(height: 20),

                        // Tebrik mesajı
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _getCelebrationMessage(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.badge.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.3),

                        const SizedBox(height: 16),

                        // Sosyal paylaşım teşviki
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.share,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      '🚀 Arkadaşlarınla Paylaş!',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getShareEncouragementMessage(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 1600.ms).slideY(begin: 0.4),

                        const SizedBox(height: 28),

                        // Aksiyon butonları
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConfettiEffects() {
    return [
      // Üstten konfeti
      Positioned(
        top: 0,
        left: MediaQuery.of(context).size.width * 0.5,
        child: ConfettiWidget(
          confettiController: _confettiController,
          blastDirection: 1.5708, // Aşağı
          emissionFrequency: 0.4,
          numberOfParticles: 20,
          maxBlastForce: 120,
          minBlastForce: 80,
          gravity: 0.4,
          colors: [
            Color(int.parse(widget.badge.colors[0].replaceFirst('#', '0xFF'))),
            Color(int.parse(widget.badge.colors[1].replaceFirst('#', '0xFF'))),
            Colors.yellow,
            Colors.orange,
            Colors.pink,
            Colors.purple,
            Colors.cyan,
            Colors.lime,
          ],
        ),
      ),

      // Sol üstten konfeti
      Positioned(
        top: 50,
        left: 30,
        child: ConfettiWidget(
          confettiController: _leftConfettiController,
          blastDirection: 0.7854, // Sağ alt
          emissionFrequency: 0.3,
          numberOfParticles: 15,
          maxBlastForce: 100,
          minBlastForce: 60,
          gravity: 0.3,
          colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green],
        ),
      ),

      // Sağ üstten konfeti
      Positioned(
        top: 50,
        right: 30,
        child: ConfettiWidget(
          confettiController: _rightConfettiController,
          blastDirection: 2.3562, // Sol alt
          emissionFrequency: 0.3,
          numberOfParticles: 15,
          maxBlastForce: 100,
          minBlastForce: 60,
          gravity: 0.3,
          colors: [Colors.blue, Colors.purple, Colors.pink, Colors.cyan],
        ),
      ),

      // Merkez patlaması
      Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        left: MediaQuery.of(context).size.width * 0.5,
        child: ConfettiWidget(
          confettiController: _centerConfettiController,
          blastDirectionality: BlastDirectionality.explosive,
          emissionFrequency: 0.2,
          numberOfParticles: 25,
          maxBlastForce: 150,
          minBlastForce: 100,
          gravity: 0.2,
          colors: [
            Colors.amber,
            Colors.amber,
            Colors.orange,
            Colors.deepOrange,
            Colors.red,
            Colors.pink,
          ],
        ),
      ),
    ];
  }

  Widget _buildAnimatedBadgeIcon() {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _bounceController,
          builder: (context, child) {
            return AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return AnimatedBuilder(
                  animation: _sparkleController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale:
                          _scaleController.value *
                          (1.0 + _bounceController.value * 0.15),
                      child: Transform.rotate(
                        angle: _rotateController.value * 0.5,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(70),
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(
                                  alpha: 0.4 + _sparkleController.value * 0.3,
                                ),
                                blurRadius: 30 + _sparkleController.value * 20,
                                spreadRadius: 10 + _sparkleController.value * 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getBadgeIcon(),
                                size: 60,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getRarityEmoji(),
                                style: const TextStyle(fontSize: 32),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Paylaş butonu
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shareBadge,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.white, width: 2),
              ),
            ),
            icon: const Icon(Icons.share, size: 20),
            label: const Text(
              'Paylaş 🚀',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Devam et butonu
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              widget.onContinue?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(
                int.parse(widget.badge.colors[0].replaceFirst('#', '0xFF')),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.celebration, size: 20),
            label: const Text(
              'Harika! 🎉',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 2000.ms).slideY(begin: 0.5);
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

  String _getMotivationalSubtitle() {
    switch (widget.badge.rarity) {
      case 1:
        return 'İlk adımını attın! 🌟';
      case 2:
        return 'Harika ilerleme gösteriyorsun! 💪';
      case 3:
        return 'Efsane performans! 🔥';
      case 4:
        return 'Mitik seviyeye ulaştın! ⚡';
      default:
        return 'Muhteşem başarı! 🎯';
    }
  }

  String _getCelebrationMessage() {
    final messages = [
      '🎉 Tebrikler ${widget.userName}! Bu rozeti hak ettin!',
      '🌟 Sürekli çaban sonuç verdi! Gurur duyuyoruz!',
      '💪 Bu başarı senin kararlılığının kanıtı!',
      '🔥 Hedeflerine doğru emin adımlarla ilerliyorsun!',
      '⭐ Bu rozet senin azmin ve disiplinin ödülü!',
      '🚀 Harika! Sağlıklı yaşam yolculuğunda bir adım daha!',
      '🎯 Mükemmel! Bu başarı seni daha da motive edecek!',
    ];

    return messages[widget.badge.id.hashCode % messages.length];
  }

  String _getShareEncouragementMessage() {
    final messages = [
      'Bu başarını arkadaşlarınla paylaş ve onları da motive et! 💫',
      'Başarı hikayeni paylaşarak başkalarına ilham ver! ✨',
      'Bu rozeti kazanmak kolay değildi! Herkese göster! 🏆',
      'Arkadaşların da senin gibi sağlıklı yaşamaya başlasın! 🌱',
      'Bu motivasyonu arkadaşlarınla paylaş, birlikte daha güçlü olun! 💪',
      'Başarı paylaşıldıkça çoğalır! Hemen arkadaşlarına göster! 🎊',
    ];

    return messages[DateTime.now().millisecond % messages.length];
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
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
