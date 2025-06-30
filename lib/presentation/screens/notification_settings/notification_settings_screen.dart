import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/dimensions.dart';
import '../../providers/notification_provider.dart';
import '../../../data/models/notification_settings_model.dart';
import '../../../data/services/notification_service.dart';

/// Bildirim ayarları ekranı
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        title: const Text(
          '🔔 Bildirim Ayarları',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: () => _notificationService.sendTestNotification(),
            tooltip: 'Test Bildirimi',
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          final settings = provider.settings;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ana bildirim açma/kapama
                _buildMainToggle(settings, provider),

                const SizedBox(height: AppDimensions.paddingL),

                // Bildirim sıklığı
                _buildIntervalSection(settings, provider),

                const SizedBox(height: AppDimensions.paddingL),

                // Zaman aralığı
                _buildTimeRangeSection(settings, provider),

                const SizedBox(height: AppDimensions.paddingL),

                // Özel zaman dilimleri
                _buildSpecialTimesSection(settings, provider),

                const SizedBox(height: AppDimensions.paddingL),

                // Günler seçimi
                _buildDaysSection(settings, provider),

                const SizedBox(height: AppDimensions.paddingL),

                // Ses ve titreşim ayarları
                _buildSoundVibrationSection(settings, provider),

                const SizedBox(height: AppDimensions.paddingXL),

                // Bildirim önizlemesi
                _buildPreviewSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainToggle(
    NotificationSettings settings,
    NotificationProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: settings.isEnabled
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.textLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              settings.isEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: settings.isEnabled
                  ? AppColors.primary
                  : AppColors.textLight,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Su Hatırlatmaları',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  settings.isEnabled
                      ? 'Bildirimler aktif, su içmeyi unutmayacaksın!'
                      : 'Bildirimler kapalı, istediğin zaman açabilirsin',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: settings.isEnabled,
            onChanged: (value) =>
                provider.updateSettings(settings.copyWith(isEnabled: value)),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.3);
  }

  Widget _buildIntervalSection(
    NotificationSettings settings,
    NotificationProvider provider,
  ) {
    if (!settings.isEnabled) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⏰', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                'Bildirim Sıklığı',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'Her ${settings.intervalHours} saatte bir hatırlatma',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Slider(
            value: settings.intervalHours.toDouble(),
            min: 1,
            max: 6,
            divisions: 5,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary.withOpacity(0.3),
            onChanged: (value) => provider.updateSettings(
              settings.copyWith(intervalHours: value.toInt()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 saat',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                '6 saat',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.3);
  }

  Widget _buildTimeRangeSection(
    NotificationSettings settings,
    NotificationProvider provider,
  ) {
    if (!settings.isEnabled) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🕐', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                'Aktif Saat Aralığı',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Row(
            children: [
              Expanded(
                child: _buildTimeSelector(
                  'Başlangıç',
                  settings.startHour,
                  (hour) => provider.updateSettings(
                    settings.copyWith(startHour: hour),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: _buildTimeSelector(
                  'Bitiş',
                  settings.endHour,
                  (hour) =>
                      provider.updateSettings(settings.copyWith(endHour: hour)),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.3);
  }

  Widget _buildTimeSelector(
    String label,
    int selectedHour,
    Function(int) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: DropdownButton<int>(
            value: selectedHour,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: List.generate(24, (index) {
              return DropdownMenuItem(
                value: index,
                child: Text('${index.toString().padLeft(2, '0')}:00'),
              );
            }),
            onChanged: (value) => onChanged(value!),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialTimesSection(
    NotificationSettings settings,
    NotificationProvider provider,
  ) {
    if (!settings.isEnabled) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌅', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                'Özel Zaman Dilimleri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          _buildTimeToggle(
            '🌅 Sabah Hatırlatmaları',
            'Güne enerjik başla!',
            settings.morningEnabled,
            (value) => provider.updateSettings(
              settings.copyWith(morningEnabled: value),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          _buildTimeToggle(
            '☀️ Öğlen Hatırlatmaları',
            'Günün ortasında tazelenme zamanı!',
            settings.afternoonEnabled,
            (value) => provider.updateSettings(
              settings.copyWith(afternoonEnabled: value),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          _buildTimeToggle(
            '🌆 Akşam Hatırlatmaları',
            'Günü su ile tamamla!',
            settings.eveningEnabled,
            (value) => provider.updateSettings(
              settings.copyWith(eveningEnabled: value),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.3);
  }

  Widget _buildTimeToggle(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDaysSection(
    NotificationSettings settings,
    NotificationProvider provider,
  ) {
    if (!settings.isEnabled) return const SizedBox.shrink();

    final dayNames = ['Paz', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt'];

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                'Aktif Günler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              final dayValue = index + 1; // 1-7 arası
              final isSelected = settings.selectedDays.contains(dayValue);

              return GestureDetector(
                onTap: () {
                  List<int> newDays = List.from(settings.selectedDays);
                  if (isSelected) {
                    newDays.remove(dayValue);
                  } else {
                    newDays.add(dayValue);
                  }
                  provider.updateSettings(
                    settings.copyWith(selectedDays: newDays),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dayNames[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.textWhite
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 700.ms, delay: 400.ms).slideY(begin: 0.3);
  }

  Widget _buildSoundVibrationSection(
    NotificationSettings settings,
    NotificationProvider provider,
  ) {
    if (!settings.isEnabled) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                'Ses ve Titreşim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Row(
            children: [
              Expanded(
                child: _buildSoundToggle(
                  '🔔 Bildirim Sesi',
                  settings.soundEnabled,
                  (value) => provider.updateSettings(
                    settings.copyWith(soundEnabled: value),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: _buildSoundToggle(
                  '📳 Titreşim',
                  settings.vibrationEnabled,
                  (value) => provider.updateSettings(
                    settings.copyWith(vibrationEnabled: value),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 500.ms).slideY(begin: 0.3);
  }

  Widget _buildSoundToggle(String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👀', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                'Bildirim Önizlemesi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suu - Su Takip',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '💧 Su İçme Zamanı! Vücudunu suyla uyandır!',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'şimdi',
                  style: TextStyle(fontSize: 10, color: AppColors.textLight),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 900.ms, delay: 600.ms).slideY(begin: 0.3);
  }
}
