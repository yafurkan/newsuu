import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/utils/app_theme.dart';

class LocationPermissionDialog extends StatefulWidget {
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;
  
  const LocationPermissionDialog({
    super.key,
    this.onPermissionGranted,
    this.onPermissionDenied,
  });

  @override
  State<LocationPermissionDialog> createState() => _LocationPermissionDialogState();
}

class _LocationPermissionDialogState extends State<LocationPermissionDialog>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      // Konum servisleri açık mı kontrol et
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _showLocationServiceDialog();
          setState(() {
            _isRequesting = false;
          });
        }
        return;
      }

      // Konum izni kontrol et
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (mounted) {
        setState(() {
          _isRequesting = false;
        });

        if (permission == LocationPermission.whileInUse || 
            permission == LocationPermission.always) {
          // İzin verildi
          Navigator.of(context).pop();
          widget.onPermissionGranted?.call();
          
          _showSuccessSnackBar();
        } else if (permission == LocationPermission.deniedForever) {
          // Kalıcı olarak reddedildi
          _showPermanentlyDeniedDialog();
        } else {
          // Reddedildi
          widget.onPermissionDenied?.call();
          _showDeniedSnackBar();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Konum izni hatası: $e'),
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

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konum Servisleri Kapalı'),
        content: const Text(
          'Hava durumu bilgisi alabilmek için lütfen cihazınızın konum servislerini açın.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openLocationSettings();
            },
            child: const Text('Ayarları Aç'),
          ),
        ],
      ),
    );
  }

  void _showPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konum İzni Gerekli'),
        content: const Text(
          'Hava durumu özelliğini kullanabilmek için uygulama ayarlarından konum iznini manuel olarak vermeniz gerekiyor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openAppSettings();
            },
            child: const Text('Ayarları Aç'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '✅ Konum izni verildi! Hava durumu güncellenecek.',
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showDeniedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.location_off, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '⚠️ Konum izni reddedildi. Demo hava durumu gösterilecek.',
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
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
                  Colors.blue.shade50,
                  Colors.white,
                  Colors.cyan.shade50,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Animasyonlu konum ikonu
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return AnimatedBuilder(
                      animation: _rotateController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.2),
                          child: Transform.rotate(
                            angle: _rotateController.value * 2 * 3.14159,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.cyan.shade400,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.shade200,
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Başlık
                Text(
                  'Konum İzni Gerekli 📍',
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: const Duration(milliseconds: 200)),

                const SizedBox(height: 16),

                // Açıklama
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.cyan.shade50],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.wb_sunny,
                        color: Colors.orange.shade600,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Size en doğru hava durumu bilgisini verebilmek için konumunuza ihtiyacımız var.',
                        style: AppTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '🌡️ Gerçek sıcaklık bilgisi\n🌤️ Güncel hava durumu\n💧 Su içme önerileri',
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().scale(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                ),

                const SizedBox(height: 24),

                // Güvenlik notu
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Konum bilginiz güvenle saklanır ve sadece hava durumu için kullanılır.',
                          style: AppTheme.bodyStyle.copyWith(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: const Duration(milliseconds: 600)),

                const SizedBox(height: 32),

                // Butonlar
                if (_isRequesting)
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Konum izni isteniyor...',
                          style: AppTheme.bodyStyle.copyWith(
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn()
                else
                  Column(
                    children: [
                      // Ana buton - İzin ver
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _requestLocationPermission,
                          icon: const Icon(Icons.location_on, size: 20),
                          label: const Text(
                            'Konum İznini Ver 🎯',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            shadowColor: Colors.blue.shade200,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Alt butonlar
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                widget.onPermissionDenied?.call();
                                _showDeniedSnackBar();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: const Text(
                                'Şimdi Değil',
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showLocationInfo();
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Daha Fazla Bilgi',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
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
            ),
          ),
        ),
      ),
    ).animate().scale(
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
    ).fadeIn();
  }

  void _showLocationInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konum Kullanımı Hakkında'),
        content: const Text(
          'Konum bilginiz:\n\n'
          '• Sadece hava durumu bilgisi almak için kullanılır\n'
          '• Üçüncü taraflarla paylaşılmaz\n'
          '• Cihazınızda saklanmaz\n'
          '• İstediğiniz zaman iptal edebilirsiniz\n\n'
          'Bu özellik olmadan demo hava durumu gösterilir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anladım'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestLocationPermission();
            },
            child: const Text('İzin Ver'),
          ),
        ],
      ),
    );
  }
}
