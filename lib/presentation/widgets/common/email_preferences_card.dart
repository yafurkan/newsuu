import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/deep_link_service.dart';
import '../../../core/utils/debug_logger.dart';

/// E-posta tercihleri yönetim kartı
class EmailPreferencesCard extends StatefulWidget {
  const EmailPreferencesCard({super.key});

  @override
  State<EmailPreferencesCard> createState() => _EmailPreferencesCardState();
}

class _EmailPreferencesCardState extends State<EmailPreferencesCard> {
  bool _dailySummary = false;
  bool _goalCompletion = true;
  bool _verificationReminder = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    // Kullanıcının e-posta tercihlerini yükle
    // Bu normalde Firestore'dan gelir
    setState(() {
      _dailySummary = false;
      _goalCompletion = true;
      _verificationReminder = true;
    });
  }

  Future<void> _sendTestEmail() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Firebase Auth e-posta doğrulama gönder (bu çalışıyor)
        await user.sendEmailVerification();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🧪 E-posta doğrulama gönderildi! (Test)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      DebugLogger.error('Test e-postası hatası: $e', tag: 'EMAIL_PREFS');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendWelcomeEmail() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Firebase Auth e-posta doğrulama gönder (hoş geldin yerine)
        await user.sendEmailVerification();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '🎉 E-posta doğrulama gönderildi! (Hoş Geldin Test)',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      DebugLogger.error('Hoş geldin e-postası hatası: $e', tag: 'EMAIL_PREFS');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Card(
      elevation: 8,
      shadowColor: Colors.blue.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.indigo.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.indigo.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'E-posta Tercihleri',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'E-posta bildirimlerinizi yönetin',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // E-posta adresi
              if (user?.email != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.email, color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user!.email!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (user.emailVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Doğrulandı',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Doğrulanmadı',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // E-posta tercihleri
              const Text(
                'Bildirim Tercihleri',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Günlük özet
              _buildPreferenceSwitch(
                title: 'Günlük Özet',
                subtitle: 'Günlük su tüketimi özetinizi e-posta ile alın',
                icon: Icons.summarize_outlined,
                value: _dailySummary,
                onChanged: (value) => setState(() => _dailySummary = value),
              ),

              // Hedef tamamlama
              _buildPreferenceSwitch(
                title: 'Hedef Tamamlama',
                subtitle:
                    'Günlük hedefinizi tamamladığınızda tebrik e-postası alın',
                icon: Icons.emoji_events_outlined,
                value: _goalCompletion,
                onChanged: (value) => setState(() => _goalCompletion = value),
              ),

              // Doğrulama hatırlatması
              _buildPreferenceSwitch(
                title: 'Doğrulama Hatırlatması',
                subtitle: 'E-posta doğrulama hatırlatmaları alın',
                icon: Icons.verified_outlined,
                value: _verificationReminder,
                onChanged: (value) =>
                    setState(() => _verificationReminder = value),
              ),

              const SizedBox(height: 24),

              // E-posta işlemleri
              const Text(
                'E-posta İşlemleri',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _sendTestEmail,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.science_outlined),
                      label: const Text('E-posta Doğrulama'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _sendWelcomeEmail,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.waving_hand_outlined),
                      label: const Text('Doğrulama Gönder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Doğrulama Başarı Ekranı Test Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testDeepLink,
                  icon: const Icon(Icons.verified_user_outlined),
                  label: const Text('Doğrulama Başarı Ekranı'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? Colors.blue.shade100 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? Colors.blue.shade600 : Colors.grey.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue.shade600,
          ),
        ],
      ),
    );
  }

  Future<void> _testDeepLink() async {
    try {
      final deepLinkService = Provider.of<DeepLinkService>(
        context,
        listen: false,
      );
      await deepLinkService.testDeepLink();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Doğrulama başarı ekranı gösterildi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      DebugLogger.error('Deep Link test hatası: $e', tag: 'EMAIL_PREFS');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Ekran gösterme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
