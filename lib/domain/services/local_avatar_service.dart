import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../../core/utils/debug_logger.dart';

/// Local avatar yönetimi servisi
/// Firebase'e yazma yapmaz, sadece local cache kullanır
class LocalAvatarService {
  static const String _avatarFileName = 'user_avatar.jpg';
  static const int _maxImageSize = 512; // 512x512 max boyut

  final ImagePicker _imagePicker = ImagePicker();

  /// Avatar dosya yolunu al
  Future<String> get _avatarPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_avatarFileName';
  }

  /// Mevcut avatar'ı al
  /// Returns: Avatar dosya yolu (varsa) veya null
  Future<String?> getAvatar() async {
    try {
      final path = await _avatarPath;
      final file = File(path);
      
      if (await file.exists()) {
        DebugLogger.info(
          '✅ Avatar bulundu: $path',
          tag: 'LOCAL_AVATAR_SERVICE',
        );
        return path;
      }
      
      DebugLogger.info(
        'ℹ️ Avatar bulunamadı',
        tag: 'LOCAL_AVATAR_SERVICE',
      );
      return null;
    } catch (e) {
      DebugLogger.error(
        'Avatar okuma hatası: $e',
        tag: 'LOCAL_AVATAR_SERVICE',
      );
      return null;
    }
  }

  /// Galeri'den avatar seç ve kaydet
  /// Returns: Kaydedilen avatar dosya yolu veya null (iptal/hata)
  Future<String?> pickAndSaveAvatar() async {
    try {
      DebugLogger.info(
        '📷 Galeri\'den avatar seçimi başlatılıyor...',
        tag: 'LOCAL_AVATAR_SERVICE',
      );

      // Galeri'den resim seç
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        DebugLogger.info(
          'ℹ️ Avatar seçimi iptal edildi',
          tag: 'LOCAL_AVATAR_SERVICE',
        );
        return null;
      }

      // Resmi işle ve kaydet
      final savedPath = await _processAndSaveImage(pickedFile.path);
      
      if (savedPath != null) {
        DebugLogger.success(
          'Avatar başarıyla kaydedildi: $savedPath',
          tag: 'LOCAL_AVATAR_SERVICE',
        );
      }

      return savedPath;
    } catch (e) {
      DebugLogger.error(
        'Avatar seçme/kaydetme hatası: $e',
        tag: 'LOCAL_AVATAR_SERVICE',
      );
      return null;
    }
  }

  /// Resmi işle ve kaydet (boyutlandır, optimize et)
  Future<String?> _processAndSaveImage(String sourcePath) async {
    try {
      // Kaynak resmi oku
      final sourceFile = File(sourcePath);
      final imageBytes = await sourceFile.readAsBytes();
      
      // Resmi decode et
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('Resim decode edilemedi');
      }

      // Resmi kare yap ve boyutlandır
      final processedImage = _resizeAndCropToSquare(originalImage);
      
      // JPEG formatında encode et
      final jpegBytes = img.encodeJpg(processedImage, quality: 85);
      
      // Local dosyaya kaydet
      final targetPath = await _avatarPath;
      final targetFile = File(targetPath);
      await targetFile.writeAsBytes(jpegBytes);

      DebugLogger.info(
        '🖼️ Avatar işlendi ve kaydedildi: ${jpegBytes.length} bytes',
        tag: 'LOCAL_AVATAR_SERVICE',
      );

      return targetPath;
    } catch (e) {
      DebugLogger.error(
        'Resim işleme hatası: $e',
        tag: 'LOCAL_AVATAR_SERVICE',
      );
      return null;
    }
  }

  /// Resmi kare yap ve boyutlandır
  img.Image _resizeAndCropToSquare(img.Image originalImage) {
    // En küçük boyutu al (kare yapmak için)
    final size = originalImage.width < originalImage.height 
        ? originalImage.width 
        : originalImage.height;

    // Merkezi kare olarak kırp
    final croppedImage = img.copyCrop(
      originalImage,
      x: (originalImage.width - size) ~/ 2,
      y: (originalImage.height - size) ~/ 2,
      width: size,
      height: size,
    );

    // Hedef boyuta resize et
    final targetSize = size > _maxImageSize ? _maxImageSize : size;
    return img.copyResize(croppedImage, width: targetSize, height: targetSize);
  }

  /// Avatar'ı sil
  Future<bool> deleteAvatar() async {
    try {
      final path = await _avatarPath;
      final file = File(path);
      
      if (await file.exists()) {
        await file.delete();
        DebugLogger.success(
          'Avatar silindi: $path',
          tag: 'LOCAL_AVATAR_SERVICE',
        );
        return true;
      }
      
      DebugLogger.info(
        'ℹ️ Silinecek avatar bulunamadı',
        tag: 'LOCAL_AVATAR_SERVICE',
      );
      return false;
    } catch (e) {
      DebugLogger.error(
        'Avatar silme hatası: $e',
        tag: 'LOCAL_AVATAR_SERVICE',
      );
      return false;
    }
  }

  /// Avatar var mı kontrol et
  Future<bool> hasAvatar() async {
    try {
      final path = await _avatarPath;
      final file = File(path);
      return await file.exists();
    } catch (e) {
      DebugLogger.error(
        'Avatar varlık kontrolü hatası: $e',
        tag: 'LOCAL_AVATAR_SERVICE',
      );
      return false;
    }
  }

  /// Avatar boyutunu al (bytes)
  Future<int?> getAvatarSize() async {
    try {
      final path = await _avatarPath;
      final file = File(path);
      
      if (await file.exists()) {
        final size = await file.length();
        DebugLogger.info(
          'Avatar boyutu: $size bytes',
          tag: 'LOCAL_AVATAR_SERVICE',
        );
        return size;
      }
      
      return null;
    } catch (e) {
      DebugLogger.error(
        'Avatar boyut kontrolü hatası: $e',
        tag: 'LOCAL_AVATAR_SERVICE',
      );
      return null;
    }
  }

  /// Avatar'ı byte array olarak al (widget'larda kullanım için)
  Future<Uint8List?> getAvatarBytes() async {
    try {
      final path = await _avatarPath;
      final file = File(path);
      
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      
      return null;
    } catch (e) {
      DebugLogger.error(
        'Avatar bytes okuma hatası: $e',
        tag: 'LOCAL_AVATAR_SERVICE',
      );
      return null;
    }
  }

  /// Varsayılan avatar widget'ı oluştur
  Widget buildDefaultAvatar({
    required double size,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Colors.grey[300],
      ),
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: iconColor ?? Colors.grey[600],
      ),
    );
  }

  /// Avatar widget'ı oluştur (local dosya varsa göster, yoksa varsayılan)
  Future<Widget> buildAvatarWidget({
    required double size,
    Color? backgroundColor,
    Color? iconColor,
  }) async {
    final avatarPath = await getAvatar();
    
    if (avatarPath != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(File(avatarPath)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    
    return buildDefaultAvatar(
      size: size,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
    );
  }
}
