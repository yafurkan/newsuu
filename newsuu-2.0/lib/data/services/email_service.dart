import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/utils/debug_logger.dart';

/// E-posta gönderim servisi
class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Hoş geldin e-postası gönder
  Future<void> sendWelcomeEmail(User user) async {
    try {
      if (user.email == null) return;

      // Firebase Extensions'ın trigger-email extension'ını kullan
      // Firestore'a email dökümanı ekleyerek e-posta tetikle
      await _firestore.collection('mail').add({
        'to': [user.email],
        'template': {
          'name': 'welcome-email',
          'data': {
            'displayName': user.displayName ?? 'Değerli Kullanıcı',
            'email': user.email,
            'appName': 'Su Takip',
            'supportEmail': 'destek@sutakip.com',
          },
        },
      });

      DebugLogger.success(
        'Hoş geldin e-postası kuyruğa eklendi: ${user.email}',
        tag: 'EMAIL',
      );
    } catch (e) {
      DebugLogger.error('Hoş geldin e-postası hatası: $e', tag: 'EMAIL');
    }
  }

  /// E-posta doğrulama hatırlatması gönder
  Future<void> sendVerificationReminder(User user) async {
    try {
      if (user.email == null || user.emailVerified) return;

      await _firestore.collection('mail').add({
        'to': [user.email],
        'template': {
          'name': 'verification-reminder',
          'data': {
            'displayName': user.displayName ?? 'Değerli Kullanıcı',
            'email': user.email,
            'verificationLink':
                'Lütfen Firebase Auth verification linkini kullanın',
          },
        },
      });

      DebugLogger.success(
        'E-posta doğrulama hatırlatması gönderildi: ${user.email}',
        tag: 'EMAIL',
      );
    } catch (e) {
      DebugLogger.error('Doğrulama hatırlatması hatası: $e', tag: 'EMAIL');
    }
  }

  /// Günlük özet e-postası gönder
  Future<void> sendDailySummary(
    User user,
    Map<String, dynamic> summaryData,
  ) async {
    try {
      if (user.email == null) return;

      await _firestore.collection('mail').add({
        'to': [user.email],
        'template': {
          'name': 'daily-summary',
          'data': {
            'displayName': user.displayName ?? 'Değerli Kullanıcı',
            'date': DateTime.now().toIso8601String().split('T')[0],
            'waterIntake': summaryData['waterIntake'] ?? 0,
            'goal': summaryData['goal'] ?? 2000,
            'percentage': summaryData['percentage'] ?? 0,
            'streak': summaryData['streak'] ?? 0,
          },
        },
      });

      DebugLogger.success(
        'Günlük özet e-postası gönderildi: ${user.email}',
        tag: 'EMAIL',
      );
    } catch (e) {
      DebugLogger.error('Günlük özet e-postası hatası: $e', tag: 'EMAIL');
    }
  }

  /// Hedef tamamlama tebrik e-postası
  Future<void> sendGoalCompletionEmail(User user, int streak) async {
    try {
      if (user.email == null) return;

      await _firestore.collection('mail').add({
        'to': [user.email],
        'template': {
          'name': 'goal-completion',
          'data': {
            'displayName': user.displayName ?? 'Değerli Kullanıcı',
            'date': DateTime.now().toIso8601String().split('T')[0],
            'streak': streak,
            'motivationMessage': _getMotivationMessage(streak),
          },
        },
      });

      DebugLogger.success(
        'Hedef tamamlama e-postası gönderildi: ${user.email}',
        tag: 'EMAIL',
      );
    } catch (e) {
      DebugLogger.error('Hedef tamamlama e-postası hatası: $e', tag: 'EMAIL');
    }
  }

  /// Streak'e göre motivasyon mesajı
  String _getMotivationMessage(int streak) {
    if (streak >= 30) {
      return 'Muhteşem! 30 günlük seri tamamladın! 🏆';
    } else if (streak >= 7) {
      return 'Harika! Bir haftalık seri tamamladın! 🎉';
    } else if (streak >= 3) {
      return 'Süper! 3 günlük seri tamamladın! 💪';
    } else {
      return 'Tebrikler! Hedefe ulaştın! 🎯';
    }
  }

  /// Test e-postası gönder
  Future<void> sendTestEmail(String email) async {
    try {
      await _firestore.collection('mail').add({
        'to': [email],
        'template': {
          'name': 'test-email',
          'data': {
            'testMessage': 'Bu bir test e-postasıdır.',
            'timestamp': DateTime.now().toIso8601String(),
          },
        },
      });

      DebugLogger.success('Test e-postası gönderildi: $email', tag: 'EMAIL');
    } catch (e) {
      DebugLogger.error('Test e-postası hatası: $e', tag: 'EMAIL');
    }
  }
}
