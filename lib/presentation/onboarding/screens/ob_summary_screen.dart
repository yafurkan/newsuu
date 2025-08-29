import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/step_progress.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/user_provider.dart';
import '../../../data/models/hydration_factors.dart';
import '../../../domain/services/hydration_goal_service.dart';

/// Onboarding özet ekranı
class ObSummaryScreen extends StatelessWidget {
  const ObSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Consumer<OnboardingProvider>(
          builder: (context, provider, child) {
            final goalMl = provider.getCalculatedGoal();
            final goalL = UnitConversions.mlToL(goalMl.toDouble());
            
            return Column(
              children: [
                // Progress göstergesi
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: StepProgress(
                    current: provider.currentStep + 1,
                    total: provider.totalSteps,
                  ),
                ),
                
                // Başlık ve emoji
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Emoji ve ikon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Center(
                          child: Text(
                            '🎉',
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Profiliniz hazır! 🎊',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Size özel hesaplanan günlük su hedefiniz 💧✨',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.brightness == Brightness.dark 
                            ? Colors.grey[400] 
                            : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Su hedefi kartı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Günlük Su Hedefiniz',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${goalL.toStringAsFixed(1)} L',
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '($goalMl ml)',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Profil özeti
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profil Özeti',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Kişisel bilgiler
                        _buildSummaryCard(
                          context,
                          title: 'Kişisel Bilgiler',
                          icon: Icons.person_outline,
                          children: [
                            _buildSummaryRow('Ağırlık', '${provider.displayWeight.toStringAsFixed(1)} ${provider.isKg ? 'kg' : 'lb'}'),
                            _buildSummaryRow('Boy', provider.isCm 
                              ? '${provider.heightCm.toStringAsFixed(1)} cm'
                              : '${provider.heightFeet}\' ${provider.heightInches}"'),
                            _buildSummaryRow('Cinsiyet', provider.gender.displayName),
                            _buildSummaryRow('Aktivite', provider.activity.displayName),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Hedefler
                        if (provider.goals.isNotEmpty)
                          _buildSummaryCard(
                            context,
                            title: 'Seçilen Hedefler',
                            icon: Icons.flag_outlined,
                            children: provider.goals.map((goalId) {
                              final goalInfo = GoalCategories.getGoalInfo(goalId);
                              return _buildGoalRow(
                                goalInfo?['icon'] ?? '🎯',
                                goalInfo?['title'] ?? goalId,
                              );
                            }).toList(),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Beslenme alışkanlıkları
                        _buildSummaryCard(
                          context,
                          title: 'Beslenme Alışkanlıkları',
                          icon: Icons.restaurant_outlined,
                          children: [
                            _buildSummaryRow('Sebze & Meyve', provider.veggies.displayName),
                            _buildSummaryRow('Şekerli İçecek', provider.sugary.displayName),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Hesaplama detayları
                        _buildCalculationDetails(context, provider),
                        
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                
                // Hata mesajı
                if (provider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.errorMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Alt butonlar
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      // Geri butonu
                      Expanded(
                        child: OutlinedButton(
                          onPressed: provider.back,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text('Geri'),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Kaydet ve başla butonu
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: !provider.isLoading
                              ? () => _completeOnboarding(context, provider)
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Kaydet ve Başla',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: theme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalRow(String icon, String title) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalculationDetails(BuildContext context, OnboardingProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.blue[900]?.withOpacity(0.3) : Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.blue[700]! : Colors.blue[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate_outlined,
                color: isDark ? Colors.blue[400] : Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Hesaplama Detayları',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isDark ? Colors.blue[400] : Colors.blue[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ağırlık: ${provider.weightKg.toStringAsFixed(1)} kg\n'
            'Aktivite: ${provider.activity.displayName}\n'
            'Sebze tüketimi: ${provider.veggies.displayName}\n'
            'Şekerli içecek: ${provider.sugary.displayName}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.blue[300] : Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding(BuildContext context, OnboardingProvider provider) async {
    try {
      final profile = await provider.complete();
      
      // Mevcut UserProvider'ı güncelle
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updatePersonalInfo(
        firstName: userProvider.firstName.isEmpty ? 'Kullanıcı' : userProvider.firstName,
        lastName: userProvider.lastName.isEmpty ? '' : userProvider.lastName,
        age: userProvider.age == 0 ? 25 : userProvider.age,
        weight: profile.weightKg,
        height: profile.heightCm,
        gender: profile.gender.name,
        activityLevel: profile.activity.name,
      );
      
      // Su hedefini güncelle
      await userProvider.setDailyWaterGoal(profile.dailyGoalMl);
      
      // İlk kez kurulumu tamamla
      await userProvider.completeFirstTime();
      
      // Başarılı tamamlama mesajı
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text('🎉'),
                SizedBox(width: 8),
                Expanded(child: Text('Profiliniz başarıyla kaydedildi!')),
              ],
            ),
            backgroundColor: Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Kısa bir animasyon bekle, sonra ana sayfaya yönlendir
        await Future.delayed(Duration(milliseconds: 500));
        
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false, // Tüm önceki route'ları temizle
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Bir hata oluştu: $e')),
              ],
            ),
            backgroundColor: Color(0xFFF44336),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
