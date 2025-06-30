import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/water_intake_model.dart';

/// Hive veri saklama servis sınıfı
class HiveService {
  static const String _userBoxName = 'user_data';
  static const String _waterIntakeBoxName = 'water_intake_data';
  static const String _settingsBoxName = 'app_settings';

  // Box referansları
  late Box<UserModel> _userBox;
  late Box<WaterIntakeModel> _waterIntakeBox;
  late Box<dynamic> _settingsBox;

  /// Hive'ı başlat
  Future<void> initHive() async {
    try {
      // Hive'ı flutter için başlat
      await Hive.initFlutter();

      // Adapter'ları kaydet
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(WaterIntakeModelAdapter());
      }

      // Box'ları aç
      _userBox = await Hive.openBox<UserModel>(_userBoxName);
      _waterIntakeBox = await Hive.openBox<WaterIntakeModel>(
        _waterIntakeBoxName,
      );
      _settingsBox = await Hive.openBox(_settingsBoxName);

      print('🗄️ Hive başarıyla başlatıldı');
    } catch (e) {
      print('❌ Hive başlatma hatası: $e');
      rethrow;
    }
  }

  /// Kullanıcı bilgilerini kaydet
  Future<void> saveUser(UserModel user) async {
    try {
      await _userBox.put('current_user', user);
      print('✅ Kullanıcı bilgileri kaydedildi');
    } catch (e) {
      print('❌ Kullanıcı kaydetme hatası: $e');
      rethrow;
    }
  }

  /// Kullanıcı bilgilerini getir
  UserModel? getUser() {
    try {
      final user = _userBox.get('current_user');
      if (user != null) {
        print('✅ Kullanıcı bilgileri yüklendi');
      }
      return user;
    } catch (e) {
      print('❌ Kullanıcı yükleme hatası: $e');
      return null;
    }
  }

  /// Su alımı kaydet
  Future<void> saveWaterIntake(WaterIntakeModel intake) async {
    try {
      final key = 'intake_${intake.timestamp.millisecondsSinceEpoch}';
      await _waterIntakeBox.put(key, intake);
      print('✅ Su alımı kaydedildi: ${intake.amount}ml');
    } catch (e) {
      print('❌ Su alımı kaydetme hatası: $e');
      rethrow;
    }
  }

  /// Bugünkü su alımlarını getir
  List<WaterIntakeModel> getTodayWaterIntakes() {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final todayIntakes = _waterIntakeBox.values
          .where(
            (intake) =>
                intake.timestamp.isAfter(startOfDay) &&
                intake.timestamp.isBefore(endOfDay),
          )
          .toList();

      // Zamana göre sırala (en yeni önce)
      todayIntakes.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      print('✅ Bugünkü su alımları yüklendi: ${todayIntakes.length} adet');
      return todayIntakes;
    } catch (e) {
      print('❌ Su alımları yükleme hatası: $e');
      return [];
    }
  }

  /// Belirli bir tarih aralığındaki su alımlarını getir
  List<WaterIntakeModel> getWaterIntakesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      final intakes = _waterIntakeBox.values
          .where(
            (intake) =>
                intake.timestamp.isAfter(startDate) &&
                intake.timestamp.isBefore(endDate),
          )
          .toList();

      intakes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return intakes;
    } catch (e) {
      print('❌ Su alımları yükleme hatası: $e');
      return [];
    }
  }

  /// Su alımını sil
  Future<void> deleteWaterIntake(WaterIntakeModel intake) async {
    try {
      final key = 'intake_${intake.timestamp.millisecondsSinceEpoch}';
      await _waterIntakeBox.delete(key);
      print('✅ Su alımı silindi');
    } catch (e) {
      print('❌ Su alımı silme hatası: $e');
      rethrow;
    }
  }

  /// İlk açılış kontrolü
  bool isFirstTime() {
    try {
      return _settingsBox.get('is_first_time', defaultValue: true);
    } catch (e) {
      print('❌ İlk açılış kontrolü hatası: $e');
      return true;
    }
  }

  /// İlk açılışı işaretle
  Future<void> markFirstTimeComplete() async {
    try {
      await _settingsBox.put('is_first_time', false);
      print('✅ İlk açılış tamamlandı');
    } catch (e) {
      print('❌ İlk açılış işaretleme hatası: $e');
    }
  }

  /// App ayarlarını kaydet
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      await _settingsBox.put(key, value);
    } catch (e) {
      print('❌ Ayar kaydetme hatası: $e');
    }
  }

  /// App ayarını getir
  T? getSetting<T>(String key, {T? defaultValue}) {
    try {
      return _settingsBox.get(key, defaultValue: defaultValue);
    } catch (e) {
      print('❌ Ayar yükleme hatası: $e');
      return defaultValue;
    }
  }

  /// Tüm verileri temizle (geliştirme amaçlı)
  Future<void> clearAllData() async {
    try {
      await _userBox.clear();
      await _waterIntakeBox.clear();
      await _settingsBox.clear();
      print('🗑️ Tüm veriler temizlendi');
    } catch (e) {
      print('❌ Veri temizleme hatası: $e');
    }
  }

  /// Box'ları kapat
  Future<void> closeBoxes() async {
    try {
      await _userBox.close();
      await _waterIntakeBox.close();
      await _settingsBox.close();
      print('📦 Hive boxlari kapatildi');
    } catch (e) {
      print('❌ Box kapatma hatası: $e');
    }
  }
}
