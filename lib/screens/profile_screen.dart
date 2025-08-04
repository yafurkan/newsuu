import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/app_theme.dart';
import '../presentation/providers/user_provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/widgets/common/email_verification_banner.dart';
import '../presentation/widgets/common/delete_account_dialog.dart';
import '../presentation/widgets/common/email_preferences_card.dart';
import 'profile_setup_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.textWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Consumer2<UserProvider, AuthProvider>(
        builder: (context, userProvider, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // E-posta doğrulama banner'ı
                const EmailVerificationBanner(),
                
                // Profil bilgileri kartı
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppTheme.primaryBlue,
                            child: Text(
                              userProvider.firstName.isNotEmpty
                                  ? userProvider.firstName
                                        .substring(0, 1)
                                        .toUpperCase()
                                  : 'K',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textWhite,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userProvider.fullName.isNotEmpty
                                      ? userProvider.fullName
                                      : 'Kullanıcı',
                                  style: AppTheme.titleStyle,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${userProvider.age} yaş',
                                  style: AppTheme.bodyStyle,
                                ),
                                if (authProvider.userEmail != null)
                                  Text(
                                    authProvider.userEmail!,
                                    style: AppTheme.bodyStyle.copyWith(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _navigateToEditProfile(context),
                            color: AppTheme.primaryBlue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Su hedefi kartı
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Günlük Su Hedefi',
                        style: AppTheme.titleStyle,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.local_drink,
                            color: AppTheme.primaryBlue,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${userProvider.dailyWaterGoal.toInt()}ml',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kişisel bilgilerinize göre otomatik hesaplanmıştır',
                        style: AppTheme.bodyStyle,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Kişisel bilgiler kartı
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kişisel Bilgiler',
                        style: AppTheme.titleStyle,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Yaş', '${userProvider.age} yaş'),
                      _buildInfoRow('Kilo', '${userProvider.weight.toInt()}kg'),
                      _buildInfoRow('Boy', '${userProvider.height.toInt()}cm'),
                      _buildInfoRow(
                        'Cinsiyet',
                        userProvider.gender == 'male' ? 'Erkek' : 'Kadın',
                      ),
                      _buildInfoRow(
                        'Aktivite Seviyesi',
                        _getActivityLevelText(userProvider.activityLevel),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Güncelleme butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToEditProfile(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Profili Güncelle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: AppTheme.textWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // E-posta tercihleri kartı
                const EmailPreferencesCard(),

                const SizedBox(height: 20),

                // Hesap yönetimi kartı
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.security_rounded,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Hesap Yönetimi',
                            style: AppTheme.titleStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // E-posta doğrulama durumu
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: authProvider.isEmailVerified
                                ? [Colors.green.shade50, Colors.teal.shade50]
                                : [Colors.orange.shade50, Colors.amber.shade50],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: authProvider.isEmailVerified
                                ? Colors.green.shade200
                                : Colors.orange.shade200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (authProvider.isEmailVerified
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100).withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: authProvider.isEmailVerified
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                authProvider.isEmailVerified
                                    ? Icons.verified_user_rounded
                                    : Icons.warning_amber_rounded,
                                color: authProvider.isEmailVerified
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authProvider.isEmailVerified
                                        ? 'E-posta Doğrulandı'
                                        : 'E-posta Doğrulanmadı',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: authProvider.isEmailVerified
                                          ? Colors.green.shade800
                                          : Colors.orange.shade800,
                                    ),
                                  ),
                                  Text(
                                    authProvider.isEmailVerified
                                        ? 'Hesabınız güvenli ✅'
                                        : 'Güvenlik için doğrulayın ⚠️',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: authProvider.isEmailVerified
                                          ? Colors.green.shade600
                                          : Colors.orange.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!authProvider.isEmailVerified)
                              ElevatedButton(
                                onPressed: () => _sendEmailVerification(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade600,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Doğrula',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Hesap silme butonu
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade50,
                              Colors.pink.shade50,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: OutlinedButton.icon(
                          onPressed: () => showDeleteAccountDialog(context),
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          label: const Text(
                            'Hesabımı Sil',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyStyle),
          Text(value, style: AppTheme.subtitleStyle),
        ],
      ),
    );
  }

  String _getActivityLevelText(String level) {
    switch (level) {
      case 'low':
        return 'Düşük';
      case 'medium':
        return 'Orta';
      case 'high':
        return 'Yüksek';
      default:
        return 'Orta';
    }
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileSetupScreen(isFirstSetup: false),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text(
            'Hesabınızdan çıkmak istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Çıkış yap
                await context.read<AuthProvider>().signOut();

                // AuthProvider'ın state'i değişince otomatik navigation olacak
                // ama ekstra güvenlik için manuel navigation de yapabiliriz
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendEmailVerification(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendEmailVerification();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Doğrulama e-postası gönderildi!'
                : authProvider.errorMessage ?? 'Bir hata oluştu',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}
