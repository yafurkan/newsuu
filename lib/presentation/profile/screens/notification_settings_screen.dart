import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../../core/utils/app_theme.dart';

/// Basit bildirim ayarları ekranı
/// Sadece Firebase Cloud Messaging açma/kapama
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Ana içerik
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Ana bildirim toggle kartı
                    _buildMainNotificationCard(),
                    
                    const SizedBox(height: 20),
                    
                    // Bilgi kartı
                    _buildInfoCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header widget'ı
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Geri butonu
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
          Expanded(
            child: Text(
              'Bildirim Ayarları',
              style: AppTheme.titleStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          
          // Bildirim ikonu
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryBlue.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.notifications,
              size: 20,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// Ana bildirim toggle kartı
  Widget _buildMainNotificationCard() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Firebase Bildirimleri',
                          style: AppTheme.titleStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Önemli güncellemeler ve hatırlatmalar',
                          style: AppTheme.bodyStyle.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Toggle switch
                  Switch(
                    value: notificationProvider.isEnabled,
                    onChanged: notificationProvider.isLoading 
                      ? null 
                      : (value) => _toggleNotifications(context, notificationProvider),
                    activeColor: AppTheme.primaryBlue,
                    activeTrackColor: AppTheme.primaryBlue.withOpacity(0.3),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Durum göstergesi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: notificationProvider.isEnabled 
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: notificationProvider.isEnabled 
                      ? AppTheme.successColor.withOpacity(0.3)
                      : AppTheme.textSecondary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      notificationProvider.isEnabled 
                        ? Icons.check_circle 
                        : Icons.cancel,
                      size: 16,
                      color: notificationProvider.isEnabled 
                        ? AppTheme.successColor
                        : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      notificationProvider.isEnabled ? 'Açık' : 'Kapalı',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: notificationProvider.isEnabled 
                          ? AppTheme.successColor
                          : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Bilgi kartı
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Bildirimler Hakkında',
                style: AppTheme.titleStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoItem(
            icon: Icons.cloud,
            title: 'Firebase Cloud Messaging',
            description: 'Önemli güncellemeler ve duyurular için kullanılır.',
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoItem(
            icon: Icons.privacy_tip,
            title: 'Gizlilik',
            description: 'Bildirimleri istediğiniz zaman açıp kapatabilirsiniz.',
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoItem(
            icon: Icons.settings,
            title: 'Varsayılan Durum',
            description: 'Bildirimler varsayılan olarak açıktır, istemezseniz kapatabilirsiniz.',
          ),
        ],
      ),
    );
  }

  /// Bilgi item widget'ı
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryBlue.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppTheme.primaryBlue,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bildirimleri aç/kapat
  Future<void> _toggleNotifications(
    BuildContext context, 
    NotificationProvider notificationProvider,
  ) async {
    try {
      await notificationProvider.toggleNotifications();
      
      // Başarı mesajı göster
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              notificationProvider.isEnabled 
                ? '✅ Bildirimler açıldı'
                : '❌ Bildirimler kapatıldı',
            ),
            backgroundColor: notificationProvider.isEnabled 
              ? AppTheme.successColor
              : AppTheme.textSecondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Hata mesajı göster
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Bildirim ayarı değiştirilemedi: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
