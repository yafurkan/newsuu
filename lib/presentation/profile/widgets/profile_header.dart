import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../../core/utils/app_theme.dart';

/// Profil ekranı header widget'ı
/// Daire avatar + kullanıcı adı + düzenleme ok'u
class ProfileHeader extends StatelessWidget {
  final VoidCallback? onTap;

  const ProfileHeader({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: AppTheme.cardDecoration,
            child: Row(
              children: [
                // Avatar
                _buildAvatar(profileProvider),
                
                const SizedBox(width: 16),
                
                // Kullanıcı bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileProvider.displayName,
                        style: AppTheme.titleStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Profili düzenle',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.primaryBlue,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Ok ikonu
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Avatar widget'ını oluştur
  Widget _buildAvatar(ProfileProvider profileProvider) {
    const double avatarSize = 60;
    
    return Stack(
      children: [
        // Ana avatar
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: _buildAvatarContent(profileProvider),
          ),
        ),
        
        // Loading indicator (avatar yüklenirken)
        if (profileProvider.isLoadingAvatar)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          ),
        
        // Düzenleme ikonu
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _changeAvatar(profileProvider),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.edit,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Avatar içeriğini oluştur (resim varsa göster, yoksa varsayılan)
  Widget _buildAvatarContent(ProfileProvider profileProvider) {
    if (profileProvider.avatarPath != null) {
      return Image.file(
        File(profileProvider.avatarPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Resim yüklenemezse varsayılan avatar göster
          return _buildDefaultAvatarContent();
        },
      );
    }
    
    return _buildDefaultAvatarContent();
  }

  /// Varsayılan avatar içeriği
  Widget _buildDefaultAvatarContent() {
    return Container(
      color: AppTheme.primaryBlue.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: 36,
        color: AppTheme.primaryBlue.withOpacity(0.7),
      ),
    );
  }

  /// Avatar değiştirme işlemi
  Future<void> _changeAvatar(ProfileProvider profileProvider) async {
    try {
      final success = await profileProvider.changeAvatar();
      
      if (!success) {
        // İptal edildi veya hata oluştu
        // ProfileProvider zaten hata mesajını yönetiyor
        return;
      }
    } catch (e) {
      // Hata durumunda log'la
      debugPrint('Avatar değiştirme hatası: $e');
    }
  }
}
