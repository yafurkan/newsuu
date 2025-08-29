import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../../core/utils/app_theme.dart';

/// Günlük su ihtiyacı detay kartı
/// Animasyonlu damla + hedef + formül açıklaması
class WaterNeedCard extends StatefulWidget {
  const WaterNeedCard({super.key});

  @override
  State<WaterNeedCard> createState() => _WaterNeedCardState();
}

class _WaterNeedCardState extends State<WaterNeedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animasyon controller'ı başlat
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Scale animasyonu (damla büyüme efekti)
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // Opacity animasyonu
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Animasyonu başlat
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.cardDecoration.copyWith(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryBlue.withOpacity(0.05),
                AppTheme.accentBlue.withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            children: [
              // Animasyonlu damla ikonu
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Günlük hedef
              Text(
                'Günlük Su Hedefiniz',
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                profileProvider.dailyGoalFormatted,
                style: AppTheme.titleStyle.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBlue,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Formül açıklaması
              _buildFormulaExplanation(profileProvider),
            ],
          ),
        );
      },
    );
  }

  /// Formül açıklaması widget'ı
  Widget _buildFormulaExplanation(ProfileProvider profileProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate,
                size: 16,
                color: AppTheme.primaryBlue.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                'Nasıl Hesaplandı?',
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Bu hedef, ağırlığınız, yaşınız, cinsiyet ve aktivite seviyeniz '
            'göz önünde bulundurularak bilimsel formüllerle hesaplanmıştır.',
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 12,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Faktörler
          _buildFactorChips(),
        ],
      ),
    );
  }

  /// Hesaplama faktörlerini chip'ler halinde göster
  Widget _buildFactorChips() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        // UserProvider'dan verileri al
        final userProvider = context.read<ProfileProvider>();
        
        final factors = [
          'Ağırlık',
          'Yaş', 
          'Cinsiyet',
          'Aktivite',
        ];

        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: factors.map((factor) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                factor,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryBlue,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Su ihtiyacı özet kartı (daha kompakt versiyon)
class WaterNeedSummaryCard extends StatelessWidget {
  final VoidCallback? onTap;

  const WaterNeedSummaryCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: AppTheme.cardDecoration.copyWith(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.05),
                  AppTheme.accentBlue.withOpacity(0.1),
                ],
              ),
            ),
            child: Row(
              children: [
                // Damla ikonu
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Bilgiler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Günlük Su İhtiyacınız',
                        style: AppTheme.bodyStyle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profileProvider.dailyGoalFormatted,
                        style: AppTheme.titleStyle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Ok ikonu
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
