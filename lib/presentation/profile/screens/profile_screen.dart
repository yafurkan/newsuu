import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/badge_provider.dart';
import '../../providers/auth_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/setting_tile.dart';
import 'water_need_detail_screen.dart';
import 'notification_settings_screen.dart';
import '../../onboarding/screens/onboarding_navigator.dart';
import '../../../core/utils/app_theme.dart';
import '../../../screens/badges_screen.dart';

/// Yeni modern profil/ayarlar ana ekranı
/// AppBar yok, ProfileHeader + 2x2 grid SettingTile'lar
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık (AppBar yerine)
            _buildHeader(context),
            
            // Profil header
            ProfileHeader(
              onTap: () => _navigateToOnboardingEdit(context),
            ),
            
            const SizedBox(height: 16),
            
            // 2x2 Ayarlar grid'i ve ek ayarlar
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 2x2 Grid
                    _buildSettingsGrid(context),
                    
                    const SizedBox(height: 24),
                    
                    // Ek ayarlar bölümü
                    _buildAdditionalSettings(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Başlık widget'ı (AppBar yerine)
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Ana sayfaya dönüş butonu
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Başlık
          Text(
            'Ayarlar',
            style: AppTheme.titleStyle.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 2x2 ayarlar grid'i
  Widget _buildSettingsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Consumer3<ProfileProvider, NotificationProvider, BadgeProvider>(
        builder: (context, profileProvider, notificationProvider, badgeProvider, child) {
          return GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Günlük ihtiyaç
              SettingTileFactory.dailyNeed(
                value: profileProvider.dailyGoalFormatted,
                onTap: () => _navigateToWaterNeedDetail(context),
                isLoading: profileProvider.isLoadingAvatar,
              ),
              
              // Bildirimler
              SettingTileFactory.notifications(
                isEnabled: notificationProvider.isEnabled,
                onTap: () => _navigateToNotifications(context),
                isLoading: notificationProvider.isLoading,
              ),
              
              // Arkadaşlar
              SettingTileFactory.friends(
                onTap: () => _navigateToFriends(context),
              ),
              
              // Başarılar
              SettingTileFactory.achievements(
                badgeCount: profileProvider.badgeStatusText,
                onTap: () => _navigateToBadges(context),
                isLoading: badgeProvider.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Ek ayarlar bölümü (liste şeklinde)
  Widget _buildAdditionalSettings(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alt başlık
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Hesap İşlemleri',
              style: AppTheme.titleStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          
          // Çıkış yap
          _buildListTile(
            icon: Icons.logout,
            title: 'Çıkış Yap',
            subtitle: 'Hesabınızdan güvenli şekilde çıkış yapın',
            iconColor: AppTheme.warningColor,
            onTap: () => _signOut(context),
          ),
          
          const SizedBox(height: 8),
          
          // Hesabı sil
          _buildListTile(
            icon: Icons.delete_forever,
            title: 'Hesabı Sil',
            subtitle: 'Tüm verilerinizi kalıcı olarak silin',
            iconColor: AppTheme.errorColor,
            onTap: () => _deleteAccount(context),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Liste tile widget'ı
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: AppTheme.cardDecoration,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        title: Text(
          title,
          style: AppTheme.titleStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.bodyStyle.copyWith(
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  /// Günlük ihtiyaç detay ekranına git
  void _navigateToWaterNeedDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WaterNeedDetailScreen(),
      ),
    );
  }

  /// Bildirimler ekranına git
  void _navigateToNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsScreen(),
      ),
    );
  }

  /// Arkadaşlar ekranına git
  void _navigateToFriends(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Arkadaşlar özelliği yakında eklenecek'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  /// Rozetler ekranına git
  void _navigateToBadges(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BadgesScreen(),
      ),
    );
  }

  /// Onboarding düzenleme ekranına git
  void _navigateToOnboardingEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OnboardingNavigator(isEditing: true),
      ),
    );
  }

  /// Çıkış yap
  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.warningColor,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authProvider = context.read<AuthProvider>();
        await authProvider.signOut();
        
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Çıkış yapılamadı: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  /// Hesabı sil
  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hesabı Sil',
          style: TextStyle(color: AppTheme.errorColor),
        ),
        content: const Text(
          'Bu işlem geri alınamaz! Tüm verileriniz kalıcı olarak silinecek.\n\n'
          'Hesabınızı silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authProvider = context.read<AuthProvider>();
        final success = await authProvider.deleteAccount();
        
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Hesabınız başarıyla silindi'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Hesap silinemedi: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }
}
