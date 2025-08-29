import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/step_progress.dart';
import '../widgets/goal_chip.dart';
import '../../providers/onboarding_provider.dart';
import '../../../data/models/hydration_factors.dart';

/// Hedefler seçimi ekranı (multi-select)
class ObGoalsScreen extends StatelessWidget {
  const ObGoalsScreen({super.key});

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
                            '🎯',
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Hedeflerinizi seçin',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Size özel motivasyon mesajları ve ipuçları için ✨ (opsiyonel)',
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
                
                // Hedef listesi
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Hedef kartları
                        ...GoalCategories.getAllGoalIds().map((goalId) {
                          final goalInfo = GoalCategories.getGoalInfo(goalId)!;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: GoalChip(
                              id: goalId,
                              title: goalInfo['title']!,
                              description: goalInfo['description']!,
                              icon: goalInfo['icon']!,
                              isSelected: provider.goals.contains(goalId),
                              onToggle: provider.toggleGoal,
                              height: 90,
                            ),
                          );
                        }).toList(),
                        
                        const SizedBox(height: 24),
                        
                        // Seçim durumu bilgisi
                        _buildSelectionInfo(context, provider),
                        
                        const SizedBox(height: 16),
                        
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
                                Icons.lightbulb_outline,
                                color: theme.brightness == Brightness.dark 
                                  ? Colors.green[400] 
                                  : Colors.green[600],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Seçtiğiniz hedeflere göre size özel motivasyon mesajları ve sağlık ipuçları göndereceğiz.',
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

  Widget _buildSelectionInfo(BuildContext context, OnboardingProvider provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedCount = provider.goals.length;
    final totalCount = GoalCategories.getAllGoalIds().length;
    
    String infoText;
    Color infoColor;
    IconData infoIcon;
    
    if (selectedCount == 0) {
      infoText = 'Hiç hedef seçmediniz (opsiyonel)';
      infoColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
      infoIcon = Icons.info_outline;
    } else if (selectedCount == 1) {
      infoText = '1 hedef seçtiniz';
      infoColor = theme.primaryColor;
      infoIcon = Icons.check_circle_outline;
    } else {
      infoText = '$selectedCount hedef seçtiniz';
      infoColor = theme.primaryColor;
      infoIcon = Icons.check_circle_outline;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selectedCount > 0 
          ? theme.primaryColor.withOpacity(0.1)
          : (isDark ? Colors.grey[800] : Colors.grey[50]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selectedCount > 0 
            ? theme.primaryColor.withOpacity(0.3)
            : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Icon(
            infoIcon,
            color: infoColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  infoText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: infoColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (selectedCount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Seçilen hedefler: ${provider.goals.map((id) => GoalCategories.getGoalInfo(id)?['title'] ?? '').join(', ')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hedef önizleme kartı
class GoalPreviewCard extends StatelessWidget {
  final Set<String> selectedGoals;

  const GoalPreviewCard({
    super.key,
    required this.selectedGoals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (selectedGoals.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Rastgele motivasyon mesajı al
    final sampleMessage = MotivationMessages.getRandomMessage(selectedGoals);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.purple[900]?.withOpacity(0.3) : Colors.purple[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.purple[700]! : Colors.purple[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: isDark ? Colors.purple[400] : Colors.purple[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Motivasyon Mesajı Önizlemesi',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isDark ? Colors.purple[400] : Colors.purple[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            sampleMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.purple[300] : Colors.purple[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
