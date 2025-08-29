import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/step_progress.dart';
import '../../providers/onboarding_provider.dart';
import '../../../data/models/user_profile.dart';

/// Cinsiyet seçimi ekranı
class ObGenderScreen extends StatelessWidget {
  const ObGenderScreen({super.key});

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
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                    MediaQuery.of(context).padding.top - 
                    MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
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
                            '👤',
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cinsiyetinizi seçin',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Su ihtiyacınızı daha doğru hesaplamak için 🎯',
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
                
                // Cinsiyet seçenekleri
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Erkek
                          _buildGenderCard(
                            context,
                            gender: Gender.male,
                            icon: Icons.male,
                            title: Gender.male.displayName,
                            isSelected: provider.gender == Gender.male,
                            onTap: () => provider.setGender(Gender.male),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Kadın
                          _buildGenderCard(
                            context,
                            gender: Gender.female,
                            icon: Icons.female,
                            title: Gender.female.displayName,
                            isSelected: provider.gender == Gender.female,
                            onTap: () => provider.setGender(Gender.female),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Belirtmek istemiyorum
                          _buildGenderCard(
                            context,
                            gender: Gender.undisclosed,
                            icon: Icons.person,
                            title: Gender.undisclosed.displayName,
                            isSelected: provider.gender == Gender.undisclosed,
                            onTap: () => provider.setGender(Gender.undisclosed),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Gizlilik notu
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark 
                                ? Colors.grey[800] 
                                : Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.brightness == Brightness.dark 
                                  ? Colors.grey[700]! 
                                  : Colors.grey[200]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.privacy_tip_outlined,
                                  color: theme.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Bu bilgi sadece su ihtiyacınızı hesaplamak için kullanılır ve gizli tutulur.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.brightness == Brightness.dark 
                                        ? Colors.grey[400] 
                                        : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
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
                ),
              ),
            ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGenderCard(
    BuildContext context, {
    required Gender gender,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
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
            
            const SizedBox(width: 20),
            
            // Başlık
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? theme.primaryColor
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
            
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
