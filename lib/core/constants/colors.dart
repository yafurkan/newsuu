import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılacak renk sabitleri
class AppColors {
  // Ana renkler
  static const Color primary = Color(0xFF4A90E2); // Su mavisi
  static const Color primaryLight = Color(0xFF7BB3F0); // Açık mavi
  static const Color primaryDark = Color(0xFF2E5F8A); // Koyu mavi

  static const Color secondary = Color(0xFF7ED321); // Başarı yeşili
  static const Color secondaryLight = Color(0xFF9FE654); // Açık yeşil
  static const Color secondaryDark = Color(0xFF5BA91A); // Koyu yeşil

  static const Color accent = Color(0xFF50E3C2); // Turkuaz
  static const Color accentLight = Color(0xFF7EEADB); // Açık turkuaz
  static const Color accentDark = Color(0xFF3BB5A0); // Koyu turkuaz

  // Arka plan renkleri
  static const Color background = Color(0xFFF8FAFB); // Açık gri
  static const Color surface = Color(0xFFFFFFFF); // Beyaz
  static const Color surfaceVariant = Color(0xFFF1F3F4); // Hafif gri

  // Metin renkleri
  static const Color textPrimary = Color(0xFF2C3E50); // Koyu lacivert
  static const Color textSecondary = Color(0xFF546E7A); // Orta gri
  static const Color textLight = Color(0xFF90A4AE); // Açık gri
  static const Color textWhite = Color(0xFFFFFFFF); // Beyaz

  // Sistem renkleri
  static const Color success = Color(0xFF4CAF50); // Başarı
  static const Color warning = Color(0xFFFF9800); // Uyarı
  static const Color error = Color(0xFFF44336); // Hata
  static const Color info = Color(0xFF2196F3); // Bilgi

  // Su seviyesi renkleri (gradient için)
  static const List<Color> waterGradient = [
    Color(0xFF4FC3F7),
    Color(0xFF29B6F6),
    Color(0xFF03A9F4),
    Color(0xFF039BE5),
  ];

  // Progress renkleri
  static const List<Color> progressGradient = [
    Color(0xFF81C784),
    Color(0xFF66BB6A),
    Color(0xFF4CAF50),
  ];

  // Card gölge rengi
  static const Color shadow = Color(0x1A000000);

  // Şeffaf renkler
  static const Color transparent = Colors.transparent;
  static const Color black12 = Colors.black12;
  static const Color black26 = Colors.black26;
  static const Color white70 = Colors.white70;
}
