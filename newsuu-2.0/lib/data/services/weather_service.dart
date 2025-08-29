import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

class WeatherService {
  /// Konum izni al ve mevcut konumu bul
  static Future<Position?> getCurrentLocation() async {
    try {
      // Konum servisleri açık mı kontrol et
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Konum servisleri kapalı');
        return null;
      }

      // Konum izni kontrol et
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Konum izni reddedildi');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Konum izni kalıcı olarak reddedildi');
        return null;
      }

      // Mevcut konumu al
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (e) {
      debugPrint('Konum alma hatası: $e');
      return null;
    }
  }

  /// Koordinatlardan şehir adını al
  static Future<String> getCityName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return placemark.locality ??
            placemark.administrativeArea ??
            'Bilinmeyen Şehir';
      }

      return 'Bilinmeyen Şehir';
    } catch (e) {
      debugPrint('Şehir adı alma hatası: $e');
      return 'Bilinmeyen Şehir';
    }
  }

  /// Hava durumu verilerini al (konum bazlı)
  static Future<WeatherData?> getWeatherData() async {
    try {
      // Önce konum iznini kontrol et
      Position? position = await getCurrentLocation();

      if (position != null) {
        // Gerçek konum varsa şehir adını al
        String cityName = await getCityName(
          position.latitude,
          position.longitude,
        );
        debugPrint(
          'Konum bulundu: $cityName (${position.latitude}, ${position.longitude})',
        );

        // Gerçek hava durumu verisi (demo olarak konum bazlı)
        return await _getLocationBasedWeatherData(position, cityName);
      } else {
        // Konum yoksa demo veri
        debugPrint('Konum bulunamadı, demo hava durumu gösteriliyor');
        return await _getDemoWeatherData();
      }
    } catch (e) {
      debugPrint('Hava durumu alma hatası: $e');
      return await _getDemoWeatherData();
    }
  }

  /// Konum bazlı hava durumu verisi (demo)
  static Future<WeatherData> _getLocationBasedWeatherData(
    Position position,
    String cityName,
  ) async {
    await Future.delayed(const Duration(seconds: 1)); // API çağrısı simülasyonu

    final now = DateTime.now();
    final hour = now.hour;

    // Konum bazlı sıcaklık hesaplama (demo)
    double baseTemp = 20.0;

    // Enlem bazlı sıcaklık ayarlaması (kuzey = soğuk, güney = sıcak)
    double latitudeAdjustment =
        (41.0 - position.latitude) * 0.5; // İstanbul referans

    // Saate göre sıcaklık
    double timeAdjustment;
    String condition;
    String icon;

    if (hour >= 6 && hour < 12) {
      // Sabah
      timeAdjustment = (hour - 6) * 2; // +0 ile +12°C arası
      condition = 'Güneşli';
      icon = 'morning';
    } else if (hour >= 12 && hour < 18) {
      // Öğlen
      timeAdjustment = 12 + (hour - 12) * 1; // +12 ile +18°C arası
      condition = 'Açık';
      icon = 'sunny';
    } else {
      // Gece
      timeAdjustment = hour >= 18 ? (24 - hour) * 1.5 : (6 - hour) * 1.5;
      condition = 'Açık';
      icon = 'night';
    }

    double temperature = baseTemp + latitudeAdjustment + timeAdjustment;

    return WeatherData(
      temperature: temperature,
      condition: condition,
      icon: icon,
      cityName: cityName,
      humidity: 60 + (position.latitude.abs() % 20).round(),
      windSpeed: 10.0 + (position.longitude.abs() % 15),
      lastUpdated: now,
    );
  }

  /// Demo hava durumu verisi
  static Future<WeatherData> _getDemoWeatherData() async {
    await Future.delayed(const Duration(seconds: 1)); // API çağrısı simülasyonu

    final now = DateTime.now();
    final hour = now.hour;

    // Saate göre demo sıcaklık
    double temperature;
    String condition;
    String icon;

    if (hour >= 6 && hour < 12) {
      // Sabah
      temperature = 18.0 + (hour - 6) * 2; // 18-30°C arası
      condition = 'Güneşli';
      icon = 'morning';
    } else if (hour >= 12 && hour < 18) {
      // Öğlen
      temperature = 25.0 + (hour - 12) * 1.5; // 25-34°C arası
      condition = 'Açık';
      icon = 'sunny';
    } else {
      // Gece
      temperature = 20.0 - (hour >= 18 ? (hour - 18) * 2 : (6 - hour) * 1.5);
      condition = 'Açık';
      icon = 'night';
    }

    return WeatherData(
      temperature: temperature,
      condition: condition,
      icon: icon,
      cityName: 'İstanbul (Demo)', // Demo şehir
      humidity: 65,
      windSpeed: 12.5,
      lastUpdated: now,
    );
  }
}

/// Hava durumu veri modeli
class WeatherData {
  final double temperature;
  final String condition;
  final String icon;
  final String cityName;
  final int humidity;
  final double windSpeed;
  final DateTime lastUpdated;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.cityName,
    required this.humidity,
    required this.windSpeed,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'condition': condition,
      'icon': icon,
      'cityName': cityName,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['temperature'].toDouble(),
      condition: json['condition'],
      icon: json['icon'],
      cityName: json['cityName'],
      humidity: json['humidity'],
      windSpeed: json['windSpeed'].toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}
