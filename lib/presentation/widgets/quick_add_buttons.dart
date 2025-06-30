import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/dimensions.dart';
import '../providers/water_provider.dart';

/// Hızlı su ekleme butonları
class QuickAddButtons extends StatelessWidget {
  const QuickAddButtons({super.key});

  // Hızlı ekleme miktarları (ml)
  static const List<double> quickAmounts = [250, 500, 750, 1000];

  // Buton ikonları
  static const List<IconData> buttonIcons = [
    Icons.local_cafe_outlined, // Fincan
    Icons.local_drink_outlined, // Bardak
    Icons.sports_bar_outlined, // Şişe
    Icons.water_drop_outlined, // Su damlası
  ];

  void _addWater(BuildContext context, double amount) {
    final waterProvider = Provider.of<WaterProvider>(context, listen: false);
    waterProvider.addWater(amount);

    // Başarı mesajı göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              '${amount.toInt()} ml su eklendi!',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: AppColors.secondary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
    );

    // Haptic feedback
    // HapticFeedback.lightImpact();
  }

  void _showCustomAmountDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Özel Miktar Ekle',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Su miktarı (ml)',
              hintText: '250',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
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
                final amount = double.tryParse(controller.text);
                if (amount != null && amount > 0 && amount <= 5000) {
                  Navigator.of(context).pop();
                  _addWater(context, amount);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Lütfen geçerli bir miktar girin (1-5000 ml)',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
              ),
              child: const Text(AppStrings.save),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hızlı ekleme butonları
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.paddingM,
            mainAxisSpacing: AppDimensions.paddingM,
            childAspectRatio: 3.0, // Daha da yüksek yapıldı
          ),
          itemCount: quickAmounts.length,
          itemBuilder: (context, index) {
            final amount = quickAmounts[index];
            final icon = buttonIcons[index];

            return _QuickAddButton(
              amount: amount,
              icon: icon,
              onPressed: () => _addWater(context, amount),
              delay: Duration(milliseconds: 100 * index),
            );
          },
        ),

        const SizedBox(height: AppDimensions.paddingM),

        // Özel miktar ekleme butonu
        SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCustomAmountDialog(context),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text(
                  AppStrings.customAmount,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                ),
              ),
            )
            .animate()
            .fadeIn(
              delay: const Duration(milliseconds: 600),
              duration: const Duration(milliseconds: 600),
            )
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final double amount;
  final IconData icon;
  final VoidCallback onPressed;
  final Duration delay;

  const _QuickAddButton({
    required this.amount,
    required this.icon,
    required this.onPressed,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.primary,
            elevation: 2,
            shadowColor: AppColors.primary.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              side: BorderSide(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.paddingS,
              horizontal: AppDimensions.paddingXS,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '${amount.toInt()} ml',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: delay, duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOut)
        .then(delay: const Duration(milliseconds: 200))
        .shimmer(
          duration: const Duration(milliseconds: 800),
          color: AppColors.primary.withOpacity(0.1),
        );
  }
}
