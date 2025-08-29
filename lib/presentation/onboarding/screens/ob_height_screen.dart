import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/segmented_unit_toggle.dart';
import '../widgets/ruler_picker.dart';
import '../widgets/step_progress.dart';
import '../../providers/onboarding_provider.dart';

/// Boy seçimi ekranı (cm / ft, inç)
class ObHeightScreen extends StatelessWidget {
  const ObHeightScreen({super.key});

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
                            '📏',
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Boyunuzu seçin',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vücut kitle indeksinizi hesaplamak için boyunuzu belirtin 📊',
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
                
                // Birim seçici
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SegmentedUnitToggle(
                    segments: const ['cm', 'ft, inç'],
                    selectedIndex: provider.heightUnitIndex,
                    onChanged: provider.onHeightUnitChanged,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Height picker (cm veya ft/in)
                Expanded(
                  child: provider.isCm 
                    ? _buildCmPicker(provider)
                    : _buildFeetInchesPicker(provider),
                ),
                
                // BMI bilgi kartı
                _buildBMICard(context, provider),
                
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

  Widget _buildCmPicker(OnboardingProvider provider) {
    return RulerPicker(
      min: 120,
      max: 220,
      step: 0.5,
      initialValue: provider.heightCm,
      unitLabel: 'cm',
      onChanged: provider.setHeight,
      height: 250,
    );
  }

  Widget _buildFeetInchesPicker(OnboardingProvider provider) {
    return DualRulerPicker(
      minFeet: 4,
      maxFeet: 7,
      initialFeet: provider.heightFeet,
      initialInches: provider.heightInches,
      onChanged: provider.setHeightFeetInches,
      height: 250,
    );
  }

  Widget _buildBMICard(BuildContext context, OnboardingProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // BMI hesapla (ağırlık ve boy varsa)
    double? bmi;
    String bmiCategory = '';
    Color bmiColor = Colors.grey;
    
    if (provider.weightKg > 0 && provider.heightCm > 0) {
      final heightM = provider.heightCm / 100;
      bmi = provider.weightKg / (heightM * heightM);
      
      if (bmi < 18.5) {
        bmiCategory = 'Zayıf';
        bmiColor = Colors.blue;
      } else if (bmi < 25) {
        bmiCategory = 'Normal';
        bmiColor = Colors.green;
      } else if (bmi < 30) {
        bmiCategory = 'Fazla kilolu';
        bmiColor = Colors.orange;
      } else {
        bmiCategory = 'Obez';
        bmiColor = Colors.red;
      }
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.monitor_weight_outlined,
            color: bmi != null ? bmiColor : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vücut Kitle İndeksi (BMI)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bmi != null 
                    ? '${bmi.toStringAsFixed(1)} - $bmiCategory'
                    : 'Ağırlık ve boy girildikten sonra hesaplanacak',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: bmi != null ? bmiColor : Colors.grey,
                    fontWeight: bmi != null ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Boy validasyon bilgi kartı
class HeightValidationCard extends StatelessWidget {
  final bool isCm;
  final double currentHeight;

  const HeightValidationCard({
    super.key,
    required this.isCm,
    required this.currentHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final minHeight = 120.0;
    final maxHeight = 220.0;
    
    final isValid = currentHeight >= minHeight && currentHeight <= maxHeight;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isValid 
          ? (isDark ? Colors.green[900] : Colors.green[50])
          : (isDark ? Colors.orange[900] : Colors.orange[50]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isValid 
            ? (isDark ? Colors.green[700]! : Colors.green[200]!)
            : (isDark ? Colors.orange[700]! : Colors.orange[200]!),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.info,
            color: isValid 
              ? (isDark ? Colors.green[400] : Colors.green[600])
              : (isDark ? Colors.orange[400] : Colors.orange[600]),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isValid 
                ? 'Boy değeri geçerli'
                : 'Boy ${minHeight.toInt()}-${maxHeight.toInt()} cm arasında olmalıdır',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isValid 
                  ? (isDark ? Colors.green[400] : Colors.green[700])
                  : (isDark ? Colors.orange[400] : Colors.orange[700]),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
