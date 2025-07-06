import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/water_provider.dart';
import '../core/utils/app_theme.dart';

class QuickAddButtons extends StatelessWidget {
  const QuickAddButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hızlı Ekleme', style: AppTheme.titleStyle),
        const SizedBox(height: 16),

        // Önceden tanımlı miktarlar
        Row(
          children: [
            Expanded(
              child: _buildQuickButton(context, 250, '250ml', Icons.coffee),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickButton(
                context,
                500,
                '500ml',
                Icons.local_drink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickButton(context, 750, '750ml', Icons.sports_bar),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Özel miktar butonu
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showCustomAmountDialog(context),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Özel Miktar Ekle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryBlue,
              side: const BorderSide(color: AppTheme.primaryBlue),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButton(
    BuildContext context,
    int amount,
    String label,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            // Haptic feedback
            HapticFeedback.lightImpact();

            final provider = Provider.of<WaterProvider>(context, listen: false);
            await provider.addWaterIntake(amount.toDouble());

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$amount ml su eklendi! 💧'),
                  backgroundColor: AppTheme.primaryBlue,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomAmountDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Özel Miktar', style: AppTheme.titleStyle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'İçtiğiniz su miktarını ml cinsinden girin:',
                style: AppTheme.bodyStyle,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Örn: 350',
                  suffixText: 'ml',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryBlue,
                      width: 2,
                    ),
                  ),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  final amount = int.tryParse(text);
                  if (amount != null && amount > 0 && amount <= 5000) {
                    Navigator.of(context).pop();

                    final provider = Provider.of<WaterProvider>(
                      context,
                      listen: false,
                    );
                    await provider.addWaterIntake(amount.toDouble());

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$amount ml su eklendi! 💧'),
                          backgroundColor: AppTheme.primaryBlue,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Lütfen geçerli bir miktar girin (1-5000 ml)',
                        ),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }
}
