import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'location_permission_dialog.dart';
import '../../../core/utils/app_theme.dart';

class LocationPermissionBanner extends StatefulWidget {
  final VoidCallback? onPermissionGranted;

  const LocationPermissionBanner({super.key, this.onPermissionGranted});

  @override
  State<LocationPermissionBanner> createState() =>
      _LocationPermissionBannerState();
}

class _LocationPermissionBannerState extends State<LocationPermissionBanner>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  bool _isVisible = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseController.repeat(reverse: true);
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    try {
      // Konum servisleri açık mı kontrol et
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showBanner();
        return;
      }

      // Konum izni kontrol et
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showBanner();
      } else if (permission == LocationPermission.whileInUse ||
                 permission == LocationPermission.always) {
        // İzin verilmişse banner'ı gizle
        _hideBanner();
      } else {
        _showBanner();
      }
    } catch (e) {
      // Hata durumunda banner'ı göster
      _showBanner();
    }
  }

  void _showBanner() {
    if (mounted) {
      setState(() {
        _isVisible = true;
        _isChecking = false;
      });
      _slideController.forward();
    }
  }

  void _hideBanner() {
    if (mounted) {
      setState(() {
        _isVisible = false;
        _isChecking = false;
      });
      _slideController.reverse();
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPermissionDialog(
        onPermissionGranted: () {
          // İzin verildikten sonra banner'ı kalıcı olarak gizle
          if (mounted) {
            setState(() {
              _isVisible = false;
            });
            _slideController.reverse();
          }
          widget.onPermissionGranted?.call();
        },
        onPermissionDenied: () {
          // Banner'ı gizle ama tekrar gösterebilir
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _checkLocationPermission();
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const SizedBox.shrink();
    }

    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade200,
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showLocationDialog,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Animasyonlu ikon
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_pulseController.value * 0.2),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(width: 16),

                        // Metin içeriği
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hava Durumu için Konum Gerekli 🌤️',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Size özel hava durumu bilgisi için konum iznine ihtiyacımız var',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Aksiyon butonları
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // İzin ver butonu
                            Container(
                              constraints: const BoxConstraints(maxWidth: 80),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _showLocationDialog,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    child: Text(
                                      'İzin Ver',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Kapat butonu
                            GestureDetector(
                              onTap: () {
                                _hideBanner();
                                // 30 saniye sonra tekrar göster
                                Future.delayed(const Duration(seconds: 30), () {
                                  if (mounted) {
                                    _checkLocationPermission();
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).animate().slideY(
      begin: -1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }
}

/// Konum izni durumunu kontrol eden yardımcı sınıf
class LocationPermissionHelper {
  static Future<bool> hasLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  static Future<void> showLocationPermissionDialog(
    BuildContext context, {
    VoidCallback? onPermissionGranted,
    VoidCallback? onPermissionDenied,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPermissionDialog(
        onPermissionGranted: onPermissionGranted,
        onPermissionDenied: onPermissionDenied,
      ),
    );
  }
}
