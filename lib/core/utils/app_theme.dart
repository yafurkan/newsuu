import 'package:flutter/material.dart';

class AppTheme {
  // Ana renkler
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color accentBlue = Color(0xFF64B5F6);
  static const Color backgroundColor = Color(0xFFF5F7FA);

  // Metin renkleri
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textWhite = Colors.white;

  // Durum renkleri
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color borderColor = Color(0xFFE0E0E0);

  // Gradientler
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, accentBlue],
  );

  // Stil tanımları
  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: textSecondary,
  );

  // Kart dekorasyonu
  static const BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  // Buton temaları
  static final ElevatedButtonThemeData elevatedButtonTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: textWhite,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
}
