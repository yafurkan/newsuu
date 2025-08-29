import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/segmented_unit_toggle.dart';
import '../widgets/ruler_picker.dart';
import '../widgets/step_progress.dart';
import '../../providers/onboarding_provider.dart';

/// Ağırlık seçimi ekranı (kg / lb)
class ObWeightScreen extends StatelessWidget {
  const ObWeightScreen({super.key});

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
                            '⚖️',
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ağırlığınızı seçin',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Su ihtiyacınızı hesaplamak için ağırlığınızı belirtin 💧',
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
                    segments: const ['kg', 'lb'],
                    selectedIndex: provider.weightUnitIndex,
                    onChanged: provider.onWeightUnitChanged,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Ruler picker
                Expanded(
                  child: RulerPicker(
                    min: provider.isKg ? 30 : 66,
                    max: provider.isKg ? 200 : 440,
                    step: provider.isKg ? 0.5 : 1,
                    initialValue: provider.displayWeight,
                    unitLabel: provider.isKg ? 'kg' : 'lb',
                    onChanged: provider.setWeight,
                    height: 250,
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
                      if (provider.currentStep > 0)
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
                      
                      if (provider.currentStep > 0)
                        const SizedBox(width: 16),
                      
                      // Devam et butonu
                      Expanded(
                        flex: provider.currentStep > 0 ? 1 : 2,
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
}

/// Ağırlık validasyon bilgi kartı
class WeightValidationCard extends StatelessWidget {
  final bool isKg;
  final double currentWeight;

  const WeightValidationCard({
    super.key,
    required this.isKg,
    required this.currentWeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final minWeight = isKg ? 30.0 : 66.0;
    final maxWeight = isKg ? 200.0 : 440.0;
    final unit = isKg ? 'kg' : 'lb';
    
    final isValid = currentWeight >= minWeight && currentWeight <= maxWeight;
    
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
                ? 'Ağırlık değeri geçerli'
                : 'Ağırlık $minWeight-$maxWeight $unit arasında olmalıdır',
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
