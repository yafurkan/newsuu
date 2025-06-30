import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/water_tracking_provider.dart';
import '../models/water_intake_model.dart';
import '../utils/app_theme.dart';

class TodayIntakeList extends StatelessWidget {
  const TodayIntakeList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterTrackingProvider>(
      builder: (context, provider, child) {
        final intakes = provider.todayIntakes;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bugünkü Su Alımları',
                  style: AppTheme.titleStyle,
                ),
                if (intakes.isNotEmpty)
                  Text(
                    '${intakes.length} kayıt',
                    style: AppTheme.captionStyle,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (intakes.isEmpty)
              _buildEmptyState()
            else
              _buildIntakeList(intakes, provider),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz su içmediniz',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Günün ilk bardağını içerek başlayın!',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIntakeList(List<WaterIntakeModel> intakes, WaterTrackingProvider provider) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          // Liste başlığı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Zaman',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'Miktar',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Su alım listesi
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: intakes.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: AppTheme.borderColor,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final intake = intakes[index];
              return _buildIntakeItem(intake, provider, context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIntakeItem(WaterIntakeModel intake, WaterTrackingProvider provider, BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    
    return Dismissible(
      key: Key(intake.timestamp.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.errorColor,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Kaydı Sil'),
              content: Text('${intake.amount}ml su alımını silmek istediğinizden emin misiniz?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                  ),
                  child: const Text('Sil', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        await provider.removeWaterIntake(intake);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${intake.amount}ml kayıt silindi'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: SnackBarAction(
                label: 'Geri Al',
                textColor: Colors.white,
                onPressed: () {
                  // Geri alma işlemi (opsiyonel)
                  provider.addWaterIntake(intake.amount, note: intake.note);
                },
              ),
            ),
          );
        }
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.lightBlue.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconForAmount(intake.amount),
            color: AppTheme.primaryBlue,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              timeFormat.format(intake.timestamp),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            if (intake.note != null && intake.note!.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  intake.note!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          _getTimeAgo(intake.timestamp),
          style: AppTheme.captionStyle,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${intake.amount}ml',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        onTap: () {
          _showEditDialog(context, intake, provider);
        },
      ),
    );
  }

  IconData _getIconForAmount(int amount) {
    if (amount <= 250) return Icons.coffee;
    if (amount <= 500) return Icons.local_drink;
    if (amount <= 750) return Icons.sports_bar;
    return Icons.water_drop;
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }

  void _showEditDialog(BuildContext context, WaterIntakeModel intake, WaterTrackingProvider provider) {
    final TextEditingController amountController = TextEditingController(
      text: intake.amount.toString(),
    );
    final TextEditingController noteController = TextEditingController(
      text: intake.note ?? '',
    );
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Kaydı Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Miktar (ml)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Not (opsiyonel)',
                  border: OutlineInputBorder(),
                ),
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
                final newAmount = int.tryParse(amountController.text);
                if (newAmount != null && newAmount > 0) {
                  await provider.updateWaterIntake(
                    intake,
                    newAmount,
                    newNote: noteController.text.trim().isNotEmpty 
                        ? noteController.text.trim() 
                        : null,
                  );
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
              ),
              child: const Text('Güncelle', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
