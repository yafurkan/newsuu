import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/app_theme.dart';
import '../presentation/providers/user_provider.dart';
import '../presentation/providers/auth_provider.dart';
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
                await context.read<AuthProvider>().signOut();

                // Çıkış sonrası login ekranına yönlendir
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
}
