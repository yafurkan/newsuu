import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/utils/app_theme.dart';
import '../presentation/providers/user_provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/widgets/common/animated_delete_account_dialog.dart';
import '../data/services/profile_photo_service.dart';
import 'animated_onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _floatController;
  bool _isDarkMode = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _shimmerController.repeat();
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _updateProfilePhoto() async {
    try {
      setState(() {
        _isUploadingPhoto = true;
      });

      final userProvider = context.read<UserProvider>();
      final File? imageFile = await ProfilePhotoService.showImageSourceDialog(
        context,
      );
      if (imageFile == null) {
        setState(() {
          _isUploadingPhoto = false;
        });
        return;
      }

      final String? newPhotoUrl = await ProfilePhotoService.updateProfilePhoto(
        imageFile,
        userProvider.profilePhotoUrl.isNotEmpty
            ? userProvider.profilePhotoUrl
            : null,
      );

      if (newPhotoUrl != null && mounted) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        await userProvider.updateProfilePhoto(newPhotoUrl);

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text('✅ Profil fotoğrafı güncellendi!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ Fotoğraf yükleme başarısız!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.1),
              Colors.white,
              AppTheme.primaryBlue.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer2<UserProvider, AuthProvider>(
            builder: (context, userProvider, authProvider, child) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Premium Header
                    _buildPremiumHeader(userProvider, authProvider),

                    const SizedBox(height: 20),

                    // Profile Photo Section
                    _buildProfilePhotoSection(userProvider),

                    const SizedBox(height: 30),

                    // Water Goal Card
                    _buildWaterGoalCard(userProvider),

                    const SizedBox(height: 20),

                    // Personal Info Card
                    _buildPersonalInfoCard(userProvider),

                    const SizedBox(height: 20),

                    // Settings Cards
                    _buildSettingsSection(authProvider),

                    const SizedBox(height: 20),

                    // Account Management
                    _buildAccountManagementSection(),

                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(
    UserProvider userProvider,
    AuthProvider authProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new),
              color: AppTheme.primaryBlue,
            ),
          ).animate().slideX(
            begin: -1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
          ),

          const SizedBox(width: 16),

          // Title with shimmer
          Expanded(
            child: AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppTheme.primaryBlue,
                        Colors.blue.shade300,
                        AppTheme.primaryBlue,
                      ],
                      stops: [
                        _shimmerController.value - 0.3,
                        _shimmerController.value,
                        _shimmerController.value + 0.3,
                      ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Profil Ayarları',
                    style: AppTheme.titleStyle.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 200)),

          // Logout button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout_rounded),
              color: Colors.white,
            ),
          ).animate().slideX(
            begin: 1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection(UserProvider userProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Photo
          Stack(
            children: [
              // Floating animation
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 5 * _floatController.value),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryBlue, Colors.blue.shade300],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: userProvider.profilePhotoUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                userProvider.profilePhotoUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultAvatar(userProvider);
                                },
                              ),
                            )
                          : _buildDefaultAvatar(userProvider),
                    ),
                  );
                },
              ),

              // Upload indicator
              if (_isUploadingPhoto)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),

              // Edit button
              Positioned(
                bottom: 0,
                right: 0,
                child:
                    GestureDetector(
                      onTap: _isUploadingPhoto ? null : _updateProfilePhoto,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.shade200,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ).animate().scale(
                      delay: const Duration(milliseconds: 800),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.elasticOut,
                    ),
              ),
            ],
          ).animate().scale(
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
          ),

          const SizedBox(height: 20),

          // User name
          Text(
            userProvider.fullName.isNotEmpty
                ? userProvider.fullName
                : 'Kullanıcı',
            style: AppTheme.titleStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 400)),

          const SizedBox(height: 8),

          // User info
          Text(
            '${userProvider.age} yaş • ${userProvider.weight.toInt()}kg • ${userProvider.height.toInt()}cm',
            style: AppTheme.bodyStyle.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
        ],
      ),
    ).animate().slideY(
      begin: 0.5,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
    );
  }

  Widget _buildDefaultAvatar(UserProvider userProvider) {
    return Center(
      child: Text(
        userProvider.firstName.isNotEmpty
            ? userProvider.firstName.substring(0, 1).toUpperCase()
            : 'K',
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildWaterGoalCard(UserProvider userProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.1),
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, Colors.blue.shade300],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_drink,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Günlük Su Hedefi',
                      style: AppTheme.titleStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kişisel bilgilerinize göre hesaplanmıştır',
                      style: AppTheme.bodyStyle.copyWith(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Goal amount
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${userProvider.dailyWaterGoal.toInt()}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'ml',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ).animate().scale(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          ),
        ],
      ),
    ).animate().slideX(
      begin: -0.5,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
    );
  }

  Widget _buildPersonalInfoCard(UserProvider userProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Kişisel Bilgiler',
                style: AppTheme.titleStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _navigateToEditProfile(context),
                icon: const Icon(Icons.edit),
                color: Colors.purple.shade600,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.purple.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Info items
          _buildInfoItem('Yaş', '${userProvider.age} yaş', Icons.cake),
          _buildInfoItem(
            'Kilo',
            '${userProvider.weight.toInt()}kg',
            Icons.monitor_weight,
          ),
          _buildInfoItem(
            'Boy',
            '${userProvider.height.toInt()}cm',
            Icons.height,
          ),
          _buildInfoItem(
            'Cinsiyet',
            userProvider.gender == 'male' ? 'Erkek' : 'Kadın',
            userProvider.gender == 'male' ? Icons.male : Icons.female,
          ),
          _buildInfoItem(
            'Aktivite',
            _getActivityLevelText(userProvider.activityLevel),
            Icons.fitness_center,
          ),
        ],
      ),
    ).animate().slideX(
      begin: 0.5,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple.shade600, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Dark Mode Toggle
          _buildSettingCard(
            title: 'Karanlık Mod',
            subtitle: 'Gece kullanımı için ideal',
            icon: Icons.dark_mode,
            iconColor: Colors.indigo.shade600,
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
                // TODO: Implement dark mode
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isDarkMode
                          ? '🌙 Karanlık mod aktif'
                          : '☀️ Aydınlık mod aktif',
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              activeColor: Colors.indigo.shade600,
            ),
          ),

          const SizedBox(height: 16),

          // Notifications
          _buildSettingCard(
            title: 'Bildirimler',
            subtitle: 'Su içme hatırlatmaları',
            icon: Icons.notifications,
            iconColor: Colors.orange.shade600,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔔 Bildirim ayarları yakında gelecek!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    ).animate().slideY(
      begin: 0.3,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: AppTheme.titleStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.bodyStyle.copyWith(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildAccountManagementSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade50, Colors.pink.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade100,
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Hesap Yönetimi',
                style: AppTheme.titleStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Delete Account Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade100, Colors.red.shade50],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showDeleteAccountDialog(context),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_forever,
                        color: Colors.red.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hesabımı Sil',
                              style: AppTheme.titleStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tüm verileriniz kalıcı olarak silinecek',
                              style: AppTheme.bodyStyle.copyWith(
                                fontSize: 12,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.red.shade600,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().scale(
            delay: const Duration(milliseconds: 600),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          ),
        ],
      ),
    ).animate().slideY(
      begin: 0.5,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 350),
                child: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Colors.blue.shade50],
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade400,
                                Colors.orange.shade600,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Çıkış Yapmak İstiyor Musun?',
                          style: AppTheme.titleStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Verileriniz güvende kalacak, istediğin zaman geri dönebilirsin! 😊',
                          style: AppTheme.bodyStyle.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: const Text('İptal'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();

                                  // Çıkış yap
                                  await context.read<AuthProvider>().signOut();

                                  if (context.mounted) {
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      '/login',
                                      (route) => false,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: const Text('Çıkış Yap'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .animate()
            .scale(
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
            )
            .fadeIn();
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AnimatedDeleteAccountDialog();
      },
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AnimatedOnboardingScreen(isFirstSetup: false),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
