import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotoService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final ImagePicker _picker = ImagePicker();

  /// Galeri veya kameradan fotoğraf seç
  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Fotoğraf seçme hatası: $e');
      return null;
    }
  }

  /// Profil fotoğrafını Firebase Storage'a yükle
  static Future<String?> uploadProfilePhoto(File imageFile) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        debugPrint('Kullanıcı oturum açmamış');
        return null;
      }

      // Dosya yolu oluştur
      final String fileName =
          'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage
          .ref()
          .child('profile_photos')
          .child(fileName);

      // Metadata ekle
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': user.uid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Dosyayı yükle
      final UploadTask uploadTask = ref.putFile(imageFile, metadata);

      // Yükleme ilerlemesini takip et
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint(
          'Yükleme ilerlemesi: ${(progress * 100).toStringAsFixed(1)}%',
        );
      });

      // Yükleme tamamlanmasını bekle
      final TaskSnapshot snapshot = await uploadTask;

      // Download URL'i al
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Profil fotoğrafı yüklendi: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      debugPrint('Profil fotoğrafı yükleme hatası: $e');
      return null;
    }
  }

  /// Eski profil fotoğrafını sil
  static Future<bool> deleteOldProfilePhoto(String photoUrl) async {
    try {
      if (photoUrl.isEmpty || !photoUrl.contains('firebase')) {
        return true; // Firebase URL değilse silmeye gerek yok
      }

      final Reference ref = _storage.refFromURL(photoUrl);
      await ref.delete();
      debugPrint('Eski profil fotoğrafı silindi: $photoUrl');
      return true;
    } catch (e) {
      debugPrint('Eski profil fotoğrafı silme hatası: $e');
      return false;
    }
  }

  /// Profil fotoğrafını güncelle (eski sil, yeni yükle)
  static Future<String?> updateProfilePhoto(
    File newImageFile,
    String? oldPhotoUrl,
  ) async {
    try {
      // Yeni fotoğrafı yükle
      final String? newPhotoUrl = await uploadProfilePhoto(newImageFile);

      if (newPhotoUrl != null &&
          oldPhotoUrl != null &&
          oldPhotoUrl.isNotEmpty) {
        // Eski fotoğrafı sil (arka planda)
        deleteOldProfilePhoto(oldPhotoUrl);
      }

      return newPhotoUrl;
    } catch (e) {
      debugPrint('Profil fotoğrafı güncelleme hatası: $e');
      return null;
    }
  }

  /// Fotoğraf seçme dialog'u göster
  static Future<File?> showImageSourceDialog(context) async {
    return await showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fotoğraf Seç'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  final File? image = await pickImage(
                    source: ImageSource.gallery,
                  );
                  navigator.pop(image);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  final File? image = await pickImage(
                    source: ImageSource.camera,
                  );
                  navigator.pop(image);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
          ],
        );
      },
    );
  }
}
