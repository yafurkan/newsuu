import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/badge_model.dart';
import '../../core/utils/debug_logger.dart';

/// Sosyal medya paylaşım servisi
class SocialShareService {
  /// Rozet paylaşım kartı oluştur ve paylaş
  Future<void> shareBadgeAchievement({
    required BadgeModel badge,
    required String userName,
    required GlobalKey repaintBoundaryKey,
  }) async {
    try {
      DebugLogger.info('Rozet paylaşımı başlatılıyor: ${badge.name}', tag: 'SOCIAL_SHARE');

      // Widget'ı görüntüye dönüştür
      final imageFile = await _captureWidget(repaintBoundaryKey);
      
      if (imageFile != null) {
        // Paylaşım metnini oluştur
        final shareText = _createShareText(badge, userName);
        
        // Paylaş
        await Share.shareXFiles(
          [XFile(imageFile.path)],
          text: shareText,
          subject: '${badge.name} Rozetini Kazandım! 🏆',
        );

        DebugLogger.success('Rozet başarıyla paylaşıldı', tag: 'SOCIAL_SHARE');
      }
    } catch (e) {
      DebugLogger.error('Rozet paylaşım hatası: $e', tag: 'SOCIAL_SHARE');
      rethrow;
    }
  }

  /// Widget'ı görüntüye dönüştür
  Future<File?> _captureWidget(GlobalKey repaintBoundaryKey) async {
    try {
      final RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return null;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      
      // Geçici dosya oluştur
      final Directory tempDir = await getTemporaryDirectory();
      final File file = File('${tempDir.path}/badge_share_${DateTime.now().millisecondsSinceEpoch}.png');
      
      await file.writeAsBytes(pngBytes);
      return file;
    } catch (e) {
      DebugLogger.error('Widget yakalama hatası: $e', tag: 'SOCIAL_SHARE');
      return null;
    }
  }

  /// Paylaşım metnini oluştur
  String _createShareText(BadgeModel badge, String userName) {
    final rarityEmoji = _getRarityEmoji(badge.rarity);
    final categoryEmoji = _getCategoryEmoji(badge.category);
    
    return '''
$rarityEmoji ${badge.name} rozetini kazandım! $categoryEmoji

${badge.description}

💡 Bilgi: ${badge.funFact}

Su Takip uygulamasıyla sağlıklı yaşama adım atıyorum! 💧

#SuTakip #SağlıklıYaşam #Su #Sağlık #Rozet #Başarı
''';
  }

  /// Nadir seviye emoji'si al
  String _getRarityEmoji(int rarity) {
    switch (rarity) {
      case 1:
        return '🥉'; // Yaygın - Bronz
      case 2:
        return '🥈'; // Nadir - Gümüş
      case 3:
        return '🥇'; // Efsane - Altın
      case 4:
        return '💎'; // Mitik - Elmas
      default:
        return '🏆';
    }
  }

  /// Kategori emoji'si al
  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'water_drinking':
        return '💧';
      case 'quick_add':
        return '⚡';
      case 'consistency':
        return '🔥';
      case 'special':
        return '⭐';
      default:
        return '🏆';
    }
  }

  /// Rozet koleksiyonu paylaş
  Future<void> shareBadgeCollection({
    required List<BadgeModel> unlockedBadges,
    required String userName,
    required UserBadgeStats stats,
  }) async {
    try {
      final shareText = '''
🏆 Su Takip Rozet Koleksiyonum 🏆

👤 $userName
📊 ${stats.unlockedBadges}/${stats.totalBadges} rozet açıldı (${stats.completionPercentage.toStringAsFixed(1)}%)

🥉 Yaygın: ${stats.commonBadges}
🥈 Nadir: ${stats.rareBadges}  
🥇 Efsane: ${stats.legendaryBadges}
💎 Mitik: ${stats.mythicBadges}

Su Takip uygulamasıyla sağlıklı yaşama devam ediyorum! 💧

#SuTakip #SağlıklıYaşam #RozetKoleksiyonu #Başarı
''';

      await Share.share(
        shareText,
        subject: 'Su Takip Rozet Koleksiyonum 🏆',
      );

      DebugLogger.success('Rozet koleksiyonu paylaşıldı', tag: 'SOCIAL_SHARE');
    } catch (e) {
      DebugLogger.error('Koleksiyon paylaşım hatası: $e', tag: 'SOCIAL_SHARE');
      rethrow;
    }
  }

  /// Günlük başarı paylaş
  Future<void> shareDailyAchievement({
    required String userName,
    required int dailyIntake,
    required int dailyGoal,
    required List<BadgeModel> todaysBadges,
  }) async {
    try {
      final percentage = ((dailyIntake / dailyGoal) * 100).toStringAsFixed(1);
      final badgeText = todaysBadges.isNotEmpty 
          ? '\n🏆 Bugün kazandığım rozetler: ${todaysBadges.map((b) => b.name).join(', ')}'
          : '';

      final shareText = '''
💧 Bugünkü Su Takip Başarım 💧

👤 $userName
🎯 Hedef: ${dailyGoal}ml
✅ İçilen: ${dailyIntake}ml (%$percentage)
${dailyIntake >= dailyGoal ? '🎉 Günlük hedef tamamlandı!' : '💪 Hedefe devam!'}$badgeText

Su Takip uygulamasıyla sağlıklı yaşıyorum! 💧

#SuTakip #SağlıklıYaşam #GünlükHedef #Su
''';

      await Share.share(
        shareText,
        subject: 'Bugünkü Su Takip Başarım 💧',
      );

      DebugLogger.success('Günlük başarı paylaşıldı', tag: 'SOCIAL_SHARE');
    } catch (e) {
      DebugLogger.error('Günlük başarı paylaşım hatası: $e', tag: 'SOCIAL_SHARE');
      rethrow;
    }
  }
}
