import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../widgets/water_need_card.dart';
import '../../onboarding/screens/onboarding_navigator.dart';
import '../../../core/utils/app_theme.dart';

/// Günlük su ihtiyacı detay ekranı
/// Suu kişisel asistan teması ile
class WaterNeedDetailScreen extends StatelessWidget {
  const WaterNeedDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header: "Suu — kişisel asistanın"
            _buildHeader(context),
            
            // Ana içerik
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Ana kart: WaterNeedCard
                    const WaterNeedCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Bilgileri güncelle butonu
                    _buildUpdateButton(context),
                    
                    const SizedBox(height: 20),
                    
                    // Ek bilgi kartı
                    _buildInfoCard(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header widget'ı
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Geri butonu
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Başlık
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suu — kişisel asistanın',
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                Text(
                  'Su ihtiyacınızı hesaplıyor',
                  style: AppTheme.bodyStyle.copyWith(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Suu maskot ikonu
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: const Icon(
              Icons.water_drop,
              size: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Bilgileri güncelle butonu
  Widget _buildUpdateButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigateToOnboardingUpdate(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: AppTheme.primaryBlue.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.edit,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Bilgileri Güncelle',
              style: AppTheme.titleStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ek bilgi kartı
  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration.copyWith(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: Colors.amber[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Bilmeniz Gerekenler',
                style: AppTheme.titleStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoItem(
            icon: Icons.trending_up,
            title: 'Kişiselleştirilmiş Hesaplama',
            description: 'Hedefiniz yaş, kilo, boy, cinsiyet ve aktivite seviyenize göre hesaplanır.',
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoItem(
            icon: Icons.schedule,
            title: 'Günlük Güncelleme',
            description: 'Bilgilerinizi güncellerseniz hedefiniz otomatik olarak yeniden hesaplanır.',
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoItem(
            icon: Icons.science,
            title: 'Bilimsel Formül',
            description: 'Hesaplama uluslararası sağlık kuruluşlarının önerilerine dayanır.',
          ),
        ],
      ),
    );
  }

  /// Bilgi item widget'ı
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryBlue.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppTheme.primaryBlue,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Onboarding güncelleme ekranına git
  void _navigateToOnboardingUpdate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OnboardingNavigator(isEditing: true),
      ),
    );
  }
}
