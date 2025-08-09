import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/app_theme.dart';

class AnimatedDeleteAccountDialog extends StatefulWidget {
  const AnimatedDeleteAccountDialog({super.key});

  @override
  State<AnimatedDeleteAccountDialog> createState() => _AnimatedDeleteAccountDialogState();
}

class _AnimatedDeleteAccountDialogState extends State<AnimatedDeleteAccountDialog>
    with TickerProviderStateMixin {
  late AnimationController _heartController;
  late AnimationController _shakeController;
  bool _isDeleting = false;
  int _currentStep = 0; // 0: Uyarı, 1: Özleyeceğiz, 2: Son onay

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Kalp animasyonunu başlat
    _heartController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _heartController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _shakeController.forward().then((_) => _shakeController.reset());
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.deleteAccount();
      
      if (mounted) {
        Navigator.of(context).pop();
        // Ana sayfaya yönlendir
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hesap silme hatası: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
              child: _buildCurrentStep(),
            ),
          ),
        ),
      ),
    ).animate().scale(
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
    ).fadeIn();
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildWarningStep();
      case 1:
        return _buildMissYouStep();
      case 2:
        return _buildFinalConfirmationStep();
      default:
        return _buildWarningStep();
    }
  }

  Widget _buildWarningStep() {
    return Padding(
      key: const ValueKey('warning'),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Uyarı ikonu
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade600],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade200,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Colors.white,
              size: 40,
            ),
          ).animate().scale(
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
          ).then().shake(duration: const Duration(milliseconds: 400)),

          const SizedBox(height: 24),

          // Başlık
          Text(
            'Hesabını Silmek İstiyor Musun?',
            style: AppTheme.titleStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: const Duration(milliseconds: 200)),

          const SizedBox(height: 16),

          // Açıklama
          Text(
            'Bu işlem geri alınamaz! Tüm verileriniz kalıcı olarak silinecek.',
            style: AppTheme.bodyStyle.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: const Duration(milliseconds: 400)),

          const SizedBox(height: 32),

          // Butonlar
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text('Devam Et'),
                ),
              ),
            ],
          ).animate().slideY(
            begin: 1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
          ),
        ],
      ),
    );
  }

  Widget _buildMissYouStep() {
    return Padding(
      key: const ValueKey('miss_you'),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Kalp ikonu
          AnimatedBuilder(
            animation: _heartController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_heartController.value * 0.2),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pink.shade400, Colors.red.shade400],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.shade200,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Başlık
          Text(
            'Seni Özleyeceğiz! 💔',
            style: AppTheme.titleStyle.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade700,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn().then().shimmer(
            duration: const Duration(milliseconds: 1500),
            color: Colors.pink.shade200,
          ),

          const SizedBox(height: 16),

          // Motivasyonel mesaj
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade50, Colors.purple.shade50],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.pink.shade200),
            ),
            child: Column(
              children: [
                Text(
                  '🌟 Su içme alışkanlığın harika gelişiyordu!',
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.pink.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Belki bir kez daha düşünmek ister misin? Sağlığın için buradayız! 💪',
                  style: AppTheme.bodyStyle.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().scale(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          ),

          const SizedBox(height: 32),

          // Butonlar - Responsive tasarım
          Column(
            children: [
              // Ana karar butonu - Kalmaya karar verdim
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.favorite, size: 20),
                  label: const Text(
                    'Kalmaya Karar Verdim! 💖',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    shadowColor: Colors.green.shade200,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Alt butonlar - Geri ve Yine de Sil
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousStep,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text(
                        'Geri',
                        style: TextStyle(fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Yine de Sil',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ).animate().slideY(
            begin: 1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
          ),
        ],
      ),
    );
  }

  Widget _buildFinalConfirmationStep() {
    return Padding(
      key: const ValueKey('final'),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Son uyarı ikonu
          AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  10 * _shakeController.value * (1 - _shakeController.value) * 4,
                  0,
                ),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade600, Colors.red.shade800],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade300,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Son başlık
          Text(
            'Son Kez Soruyoruz!',
            style: AppTheme.titleStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn().then().shimmer(
            duration: const Duration(milliseconds: 1500),
            color: Colors.red.shade200,
          ),

          const SizedBox(height: 16),

          // Son uyarı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              '⚠️ Bu işlem GERİ ALINAMAZ!\n\n• Tüm su içme verileriniz silinecek\n• Kazandığınız rozetler kaybolacak\n• Hesabınız kalıcı olarak silinecek',
              style: AppTheme.bodyStyle.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().scale(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          ),

          const SizedBox(height: 32),

          // Son butonlar
          if (_isDeleting)
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hesabınız siliniyor...',
                    style: AppTheme.bodyStyle.copyWith(
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn()
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previousStep,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Geri'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _deleteAccount,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Evet, Hesabımı Sil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ).animate().slideY(
              begin: 1,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
            ),
        ],
      ),
    );
  }
}