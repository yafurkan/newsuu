import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../data/services/weather_service.dart';
import '../../core/utils/app_theme.dart';

class WeatherTimeWidget extends StatefulWidget {
  final String userName;
  
  const WeatherTimeWidget({
    super.key,
    required this.userName,
  });

  @override
  State<WeatherTimeWidget> createState() => _WeatherTimeWidgetState();
}

class _WeatherTimeWidgetState extends State<WeatherTimeWidget>
    with TickerProviderStateMixin {
  late AnimationController _sunController;
  late AnimationController _cloudController;
  late AnimationController _pulseController;
  
  WeatherData? _weatherData;
  DateTime _currentTime = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _sunController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _cloudController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _sunController.repeat();
    _cloudController.repeat();
    _pulseController.repeat(reverse: true);
    
    _loadWeatherData();
    _startTimeUpdater();
  }

  @override
  void dispose() {
    _sunController.dispose();
    _cloudController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _loadWeatherData() async {
    try {
      final weatherData = await WeatherService.getWeatherData();
      if (mounted) {
        setState(() {
          _weatherData = weatherData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startTimeUpdater() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
        _startTimeUpdater();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _getTimeBasedGradient(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getTimeBasedColor().withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Hoşgeldin mesajı
          Row(
            children: [
              _buildTimeIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Merhaba, ${widget.userName}!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
                    
                    Text(
                      _getGreetingMessage(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Saat ve hava durumu
          Row(
            children: [
              // Saat bilgisi
              Expanded(
                child: _buildTimeSection(),
              ),
              
              const SizedBox(width: 16),
              
              // Hava durumu bilgisi
              Expanded(
                child: _buildWeatherSection(),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(
      begin: -0.5,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
    );
  }

  Widget _buildTimeIcon() {
    final hour = _currentTime.hour;
    
    if (hour >= 6 && hour < 12) {
      // Sabah - Güneş doğuyor
      return AnimatedBuilder(
        animation: _sunController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _sunController.value * 2 * 3.14159,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.orange.shade300,
                    Colors.orange.shade600,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade200,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.wb_sunny,
                color: Colors.white,
                size: 28,
              ),
            ),
          );
        },
      );
    } else if (hour >= 12 && hour < 18) {
      // Öğlen - Parlak güneş
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_pulseController.value * 0.1),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.yellow.shade300,
                    Colors.orange.shade500,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.shade200,
                    blurRadius: 25,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.wb_sunny,
                color: Colors.white,
                size: 28,
              ),
            ),
          );
        },
      );
    } else {
      // Gece - Ay ve yıldızlar
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_pulseController.value * 0.05),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.indigo.shade300,
                    Colors.indigo.shade600,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.shade200,
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.nightlight_round,
                color: Colors.white,
                size: 28,
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildTimeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Türkiye Saati',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('HH:mm:ss').format(_currentTime),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            DateFormat('dd MMMM yyyy', 'tr_TR').format(_currentTime),
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    ).animate().scale(
      delay: const Duration(milliseconds: 600),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Widget _buildWeatherSection() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
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
      );
    }

    if (_weatherData == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_off,
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Hava Durumu',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Yüklenemedi',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.thermostat,
                color: Colors.white.withOpacity(0.8),
                size: 14,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _weatherData!.cityName,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: Text(
                  '${_weatherData!.temperature.round()}°C',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              _buildWeatherIcon(),
            ],
          ),
          Text(
            _weatherData!.condition,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().scale(
      delay: const Duration(milliseconds: 800),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Widget _buildWeatherIcon() {
    IconData iconData;
    Color iconColor;
    
    switch (_weatherData!.icon) {
      case 'sunny':
        iconData = Icons.wb_sunny;
        iconColor = Colors.yellow.shade300;
        break;
      case 'morning':
        iconData = Icons.wb_sunny;
        iconColor = Colors.orange.shade300;
        break;
      case 'night':
        iconData = Icons.nightlight_round;
        iconColor = Colors.indigo.shade300;
        break;
      case 'cloudy':
        iconData = Icons.cloud;
        iconColor = Colors.grey.shade300;
        break;
      case 'rainy':
        iconData = Icons.grain;
        iconColor = Colors.blue.shade300;
        break;
      default:
        iconData = Icons.wb_sunny;
        iconColor = Colors.yellow.shade300;
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.1),
          child: Icon(
            iconData,
            color: iconColor,
            size: 20,
          ),
        );
      },
    );
  }

  LinearGradient _getTimeBasedGradient() {
    final hour = _currentTime.hour;
    
    if (hour >= 6 && hour < 12) {
      // Sabah
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.orange.shade400,
          Colors.pink.shade400,
          Colors.purple.shade400,
        ],
      );
    } else if (hour >= 12 && hour < 18) {
      // Öğlen
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.blue.shade400,
          Colors.cyan.shade400,
          Colors.teal.shade400,
        ],
      );
    } else {
      // Gece
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.indigo.shade600,
          Colors.purple.shade600,
          Colors.deepPurple.shade600,
        ],
      );
    }
  }

  Color _getTimeBasedColor() {
    final hour = _currentTime.hour;
    
    if (hour >= 6 && hour < 12) {
      return Colors.orange;
    } else if (hour >= 12 && hour < 18) {
      return Colors.blue;
    } else {
      return Colors.indigo;
    }
  }

  String _getGreetingMessage() {
    final hour = _currentTime.hour;
    
    if (hour >= 6 && hour < 12) {
      return 'Günaydın! Su içmeyi unutma ☀️';
    } else if (hour >= 12 && hour < 18) {
      return 'İyi öğlenler! Hidrasyon zamanı 💧';
    } else if (hour >= 18 && hour < 22) {
      return 'İyi akşamlar! Su hedefine yaklaştın mı? 🌅';
    } else {
      return 'İyi geceler! Yarın için hazırlan 🌙';
    }
  }
}