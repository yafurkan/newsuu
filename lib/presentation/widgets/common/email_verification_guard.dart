import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_theme.dart';
import '../../providers/auth_provider.dart';

/// E-posta doğrulanmamış kullanıcıları engelleyen widget
class EmailVerificationGuard extends StatelessWidget {
  final Widget child;
  final String? customMessage;
  final bool showFullScreen;

  const EmailVerificationGuard({
    super.key,
    required this.child,
    this.customMessage,
    this.showFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // E-posta doğrulanmışsa normal widget'ı göster
        if (authProvider.isEmailVerified) {
          return child;
        }

        // E-posta doğrulanmamışsa engelleme ekranı göster
        if (showFullScreen) {
          return _buildFullScreenBlock(context, authProvider);
        } else {
          return _buildInlineBlock(context, authProvider);
        }
      },
    );
  }

  Widget _buildFullScreenBlock(BuildContext context, AuthProvider authProvider) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  size: 64,
                  color: Colors.orange.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'E-posta Doğrulama Gerekli',
                style: AppTheme.titleStyle.copyWith(
                  fontSize: 24,
                  color: Colors.orange.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                customMessage ??
                    'Bu özelliği kullanabilmek için lütfen e-posta adresinizi doğrulayın.',
                style: AppTheme.bodyStyle.copyWith(
                  color: Colors.orange.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildActionButtons(context, authProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInlineBlock(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.indigo.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.security_rounded,
                size: 40,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Güvenlik Doğrulaması',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade200,
                  width: 1,
                ),
              ),
              child: Text(
                customMessage ??
                    'Bu özelliği kullanabilmek için lütfen e-posta adresinizi doğrulayın.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            _buildActionButtons(context, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _sendVerification(context, authProvider),
            icon: const Icon(Icons.send_rounded, size: 20),
            label: const Text(
              'Doğrulama E-postası Gönder',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              elevation: 3,
              shadowColor: Colors.blue.shade300,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.shade300,
              width: 1,
            ),
          ),
          child: TextButton.icon(
            onPressed: () => _checkVerification(context, authProvider),
            icon: Icon(
              Icons.refresh_rounded,
              color: Colors.blue.shade600,
              size: 18,
            ),
            label: Text(
              'Doğrulamayı Kontrol Et',
              style: TextStyle(
                color: Colors.blue.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendVerification(BuildContext context, AuthProvider authProvider) async {
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

  Future<void> _checkVerification(BuildContext context, AuthProvider authProvider) async {
    await authProvider.reloadUser();

    if (context.mounted && authProvider.isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 E-posta başarıyla doğrulandı!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}