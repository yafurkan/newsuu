import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/step_progress.dart';
import '../../providers/onboarding_provider.dart';
import '../../../data/models/user_profile.dart';

/// Sebze ve meyve tüketim sıklığı ekranı
class ObVeggiesScreen extends StatelessWidget {
  const ObVeggiesScreen({super.key});

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
                            '🥬',
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sebze ve meyve tüketiminiz',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sebze ve meyveler doğal hidrasyon sağlar 🍎🥒',
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
                
                const SizedBox(height: 48),
                
                // Sebze seçenekleri
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Nadiren
                        _buildVeggieCard(
                          context,
                          frequency: VeggieFreq.rare,
                          icon: Icons.schedule,
                          title: VeggieFreq.rare.displayName,
                          description: VeggieFreq.rare.description,
                          isSelected: provider.veggies == VeggieFreq.rare,
                          onTap: () => provider.setVeggies(VeggieFreq.rare),
                          adjustment: '0%',
                          adjustmentColor: Colors.grey,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Düzenli olarak
                        _buildVeggieCard(
                          context,
                          frequency: VeggieFreq.daily,
                          icon: Icons.eco,
                          title: VeggieFreq.daily.displayName,
                          description: VeggieFreq.daily.description,
                          isSelected: provider.veggies == VeggieFreq.daily,
                          onTap: () => provider.setVeggies(VeggieFreq.daily),
                          adjustment: '-2%',
                          adjustmentColor: Colors.green,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Sıklıkla
                        _buildVeggieCard(
                          context,
                          frequency: VeggieFreq.frequent,
                          icon: Icons.local_florist,
                          title: VeggieFreq.frequent.displayName,
                          description: VeggieFreq.frequent.description,
                          isSelected: provider.veggies == VeggieFreq.frequent,
                          onTap: () => provider.setVeggies(VeggieFreq.frequent),
                          adjustment: '-5%',
                          adjustmentColor: Colors.green,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Bilgi kartı
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark 
                              ? Colors.green[900]?.withOpacity(0.3)
                              : Colors.green[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.brightness == Brightness.dark 
                                ? Colors.green[700]! 
                                : Colors.green[200]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.brightness == Brightness.dark 
                                  ? Colors.green[400] 
                                  : Colors.green[600],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Sebze ve meyveler doğal su içeriği sayesinde günlük su ihtiyacınızı azaltır.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.brightness == Brightness.dark 
                                      ? Colors.green[300] 
                                      : Colors.green[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24), // Alt padding ekle
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
                      
                      // Devam et butonu
                      Expanded(
                        child: ElevatedButton(
                          onPressed: provider.isCurrentStepValid && !provider.isLoading
                              ? provider.next
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
                                  'Devam Et',
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

  Widget _buildVeggieCard(
    BuildContext context, {
    required VeggieFreq frequency,
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
    required String adjustment,
    required Color adjustmentColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : (isDark ? Colors.grey[800] : Colors.grey[50]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // İkon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.primaryColor
                    : (isDark ? Colors.grey[700] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                size: 28,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Metin içeriği
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? theme.primaryColor
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                      ),
                      // Su azaltma göstergesi
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? adjustmentColor.withOpacity(0.2)
                              : (isDark ? Colors.grey[700] : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          adjustment,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? adjustmentColor
                                : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Seçim göstergesi
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.primaryColor
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? theme.primaryColor
                      : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
