import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/calculations.dart';
import '../providers/water_provider.dart';

/// Bugünkü su alımları listesi
class TodayIntakeList extends StatelessWidget {
  const TodayIntakeList({super.key});

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getTimeCategory(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour >= 6 && hour < 12) {
      return AppStrings.morning;
    } else if (hour >= 12 && hour < 18) {
      return AppStrings.afternoon;
    } else if (hour >= 18 && hour < 22) {
      return AppStrings.evening;
    } else {
      return AppStrings.night;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case AppStrings.morning:
        return const Color(0xFFFFA726); // Turuncu
      case AppStrings.afternoon:
        return const Color(0xFF42A5F5); // Mavi
      case AppStrings.evening:
        return const Color(0xFF9C27B0); // Mor
      default:
        return const Color(0xFF5C6BC0); // İndigo
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case AppStrings.morning:
        return Icons.wb_sunny_outlined;
      case AppStrings.afternoon:
        return Icons.wb_cloudy_outlined;
      case AppStrings.evening:
        return Icons.brightness_3_outlined;
      default:
        return Icons.nights_stay_outlined;
    }
  }

  void _removeIntake(BuildContext context, int index) {
    final waterProvider = Provider.of<WaterProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Su Alımını Sil',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Bu su alımını silmek istediğinizden emin misiniz?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                AppStrings.cancel,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                waterProvider.removeWaterIntake(index);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Su alımı silindi',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textWhite,
              ),
              child: const Text(AppStrings.delete),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, waterProvider, child) {
        final intakes = waterProvider.todayIntakes;

        if (intakes.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.water_drop_outlined,
                  size: 48,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  'Henüz su eklemediniz',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingS),
                Text(
                  'Yukarıdaki butonları kullanarak su ekleyin',
                  style: TextStyle(fontSize: 14, color: AppColors.textLight),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Liste başlığı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusM),
                    topRight: Radius.circular(AppDimensions.radiusM),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.history, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Bugünkü Su Alımları',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${intakes.length}',
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Su alımları listesi
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: intakes.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                itemBuilder: (context, index) {
                  final intake =
                      intakes[intakes.length - 1 - index]; // En yenisi üstte
                  final actualIndex = intakes.length - 1 - index;
                  final time = _formatTime(intake.timestamp);
                  final category = _getTimeCategory(intake.timestamp);
                  final categoryColor = _getCategoryColor(category);
                  final categoryIcon = _getCategoryIcon(category);

                  return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingS,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            categoryIcon,
                            color: categoryColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          WaterCalculations.formatWaterAmount(intake.amount),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '$category • $time',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: AppColors.error.withOpacity(0.7),
                            size: 20,
                          ),
                          onPressed: () => _removeIntake(context, actualIndex),
                        ),
                      )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 100 * index),
                        duration: const Duration(milliseconds: 400),
                      )
                      .slideX(begin: 0.3, end: 0, curve: Curves.easeOut);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
