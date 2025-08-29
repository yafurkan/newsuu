import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';

/// Ayarlar grid'i için tile widget'ı
/// 2x2 grid'de kullanılacak ayar kartları
class SettingTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? badge; // Durum rozeti için
  final bool isLoading;

  const SettingTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.onTap,
    this.badge,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration.copyWith(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst kısım: İkon ve badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (iconColor ?? AppTheme.primaryBlue).withOpacity(0.1),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor ?? AppTheme.primaryBlue,
                  ),
                ),
                if (badge != null) badge!,
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Başlık
            Text(
              title,
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Değer
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryBlue.withOpacity(0.6),
                  ),
                ),
              )
            else
              Text(
                value,
                style: AppTheme.titleStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}

/// Durum rozeti widget'ı (bildirimler için)
class StatusBadge extends StatelessWidget {
  final String text;
  final bool isActive;

  const StatusBadge({
    super.key,
    required this.text,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive 
          ? AppTheme.successColor.withOpacity(0.1)
          : AppTheme.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive 
            ? AppTheme.successColor.withOpacity(0.3)
            : AppTheme.textSecondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isActive 
            ? AppTheme.successColor
            : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

/// Arkadaşlar için özel ikon badge'i
class AddFriendsBadge extends StatelessWidget {
  const AddFriendsBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.purple.withOpacity(0.1),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: const Icon(
        Icons.add,
        size: 14,
        color: Colors.purple,
      ),
    );
  }
}

/// Önceden tanımlanmış setting tile'ları için factory metodları
class SettingTileFactory {
  /// Günlük ihtiyaç tile'ı
  static SettingTile dailyNeed({
    required String value,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return SettingTile(
      title: 'Günlük ihtiyaç',
      value: value,
      icon: Icons.water_drop,
      iconColor: AppTheme.primaryBlue,
      onTap: onTap,
      isLoading: isLoading,
    );
  }

  /// Bildirimler tile'ı
  static SettingTile notifications({
    required bool isEnabled,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return SettingTile(
      title: 'Bildirimler',
      value: isEnabled ? 'Açık' : 'Kapalı',
      icon: Icons.notifications,
      iconColor: isEnabled ? AppTheme.successColor : AppTheme.textSecondary,
      onTap: onTap,
      badge: StatusBadge(
        text: isEnabled ? 'Açık' : 'Kapalı',
        isActive: isEnabled,
      ),
      isLoading: isLoading,
    );
  }

  /// Arkadaşlar tile'ı
  static SettingTile friends({
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return SettingTile(
      title: 'Arkadaşlar',
      value: 'Ekle',
      icon: Icons.people,
      iconColor: Colors.purple,
      onTap: onTap,
      badge: const AddFriendsBadge(),
      isLoading: isLoading,
    );
  }

  /// Başarılar tile'ı
  static SettingTile achievements({
    required String badgeCount,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return SettingTile(
      title: 'Başarılar',
      value: badgeCount,
      icon: Icons.emoji_events,
      iconColor: Colors.amber[700],
      onTap: onTap,
      isLoading: isLoading,
    );
  }
}
