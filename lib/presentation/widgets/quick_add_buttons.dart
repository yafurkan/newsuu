import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/dimensions.dart';
import '../providers/water_provider.dart';

/// Hızlı su ekleme butonları - Firebase bağımsız optimistic UI
class QuickAddButtons extends StatefulWidget {
  const QuickAddButtons({super.key});

  @override
  State<QuickAddButtons> createState() => _QuickAddButtonsState();
}

class _QuickAddButtonsState extends State<QuickAddButtons> {
  // Loading state için her buton için ayrı kontrol
  final Map<double, bool> _loadingStates = {};
  bool _customAmountLoading = false;

  // Hızlı ekleme miktarları (ml)
  static const List<double> quickAmounts = [250, 500, 750, 1000];

  // Buton ikonları
  static const List<IconData> buttonIcons = [
    Icons.local_cafe_outlined, // Fincan
    Icons.local_drink_outlined, // Bardak
    Icons.sports_bar_outlined, // Şişe
    Icons.water_drop_outlined, // Su damlası
  ];

  /// Firebase bağımsız su ekleme - Optimistic UI
  Future<void> _addWaterOptimistic(BuildContext context, double amount) async {
    if (_loadingStates[amount] == true) return; // Zaten işleniyor

    // 1. Anında loading state'i aktif et
    setState(() {
      _loadingStates[amount] = true;
    });

    try {
      final waterProvider = Provider.of<WaterProvider>(context, listen: false);
      
      // 2. Anında başarı mesajı göster (optimistic)
      if (mounted) {
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
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
        );
      }

      // 3. Background'da Firebase'e kaydet (fire-and-forget)
      _saveToFirebaseInBackground(waterProvider, amount);

    } catch (e) {
      // Hata durumunda bile kullanıcıya pozitif feedback ver
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.cloud_off, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${amount.toInt()} ml su eklendi! (Offline)',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: AppColors.warning,
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
        );
      }
    } finally {
      // 4. Loading state'i hızlıca temizle (500ms sonra)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _loadingStates[amount] = false;
          });
        }
      });
    }
  }

  /// Background'da Firebase'e kaydet - kullanıcı deneyimini etkilemez
  void _saveToFirebaseInBackground(WaterProvider waterProvider, double amount) {
    // Fire-and-forget: Kullanıcı deneyimini etkilemeden background'da çalışır
    Future.microtask(() async {
      try {
        await waterProvider.addWaterIntake(amount).timeout(
          const Duration(seconds: 5), // Daha uzun timeout
          onTimeout: () {
            // Timeout olursa da sorun yok, offline queue'ya eklenir
            return;
          },
        );
      } catch (e) {
        // Background hatası - kullanıcıyı rahatsız etme
        debugPrint('Background Firebase save error: $e');
      }
    });
  }

  void _showCustomAmountDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                  onPressed: _customAmountLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text(
                    AppStrings.cancel,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: _customAmountLoading ? null : () async {
                    final amount = double.tryParse(controller.text);
                    if (amount != null && amount > 0 && amount <= 5000) {
                      setDialogState(() {
                        _customAmountLoading = true;
                      });
                      
                      Navigator.of(context).pop();
                      await _addWaterOptimistic(context, amount);
                      
                      if (mounted) {
                        setState(() {
                          _customAmountLoading = false;
                        });
                      }
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
                  child: _customAmountLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(AppStrings.save),
                ),
              ],
            );
          },
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
            childAspectRatio: 3.0,
          ),
          itemCount: quickAmounts.length,
          itemBuilder: (context, index) {
            final amount = quickAmounts[index];
            final icon = buttonIcons[index];

            return _QuickAddButton(
              amount: amount,
              icon: icon,
              isLoading: _loadingStates[amount] ?? false,
              onPressed: () => _addWaterOptimistic(context, amount),
              delay: Duration(milliseconds: 100 * index),
            );
          },
        ),

        const SizedBox(height: AppDimensions.paddingM),

        // Özel miktar ekleme butonu
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _customAmountLoading ? null : () => _showCustomAmountDialog(context),
            icon: _customAmountLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : const Icon(Icons.add_circle_outline),
            label: Text(
              _customAmountLoading ? 'Ekleniyor...' : AppStrings.customAmount,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _customAmountLoading ? AppColors.textSecondary : AppColors.primary,
              side: BorderSide(color: _customAmountLoading ? AppColors.textSecondary : AppColors.primary),
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
  final bool isLoading;

  const _QuickAddButton({
    required this.amount,
    required this.icon,
    required this.onPressed,
    required this.delay,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isLoading ? AppColors.surface.withValues(alpha: 0.5) : AppColors.surface,
        foregroundColor: isLoading ? AppColors.textSecondary : AppColors.primary,
        elevation: isLoading ? 0 : 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          side: BorderSide(
            color: isLoading
                ? AppColors.textSecondary.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.3),
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
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          else
            Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            isLoading ? 'Eklendi!' : '${amount.toInt()} ml',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isLoading ? AppColors.secondary : AppColors.primary,
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
      color: AppColors.primary.withValues(alpha: 0.1),
    );
  }
}