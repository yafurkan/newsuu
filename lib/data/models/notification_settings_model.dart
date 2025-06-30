import 'package:hive/hive.dart';

part 'notification_settings_model.g.dart';

/// Bildirim ayarları model sınıfı
@HiveType(typeId: 2)
class NotificationSettings extends HiveObject {
  @HiveField(0)
  bool isEnabled; // Bildirimler açık mı?

  @HiveField(1)
  int intervalHours; // Bildirim sıklığı (saat)

  @HiveField(2)
  int startHour; // Başlangıç saati

  @HiveField(3)
  int endHour; // Bitiş saati

  @HiveField(4)
  bool morningEnabled; // Sabah bildirimleri

  @HiveField(5)
  bool afternoonEnabled; // Öğlen bildirimleri

  @HiveField(6)
  bool eveningEnabled; // Akşam bildirimleri

  @HiveField(7)
  List<int> selectedDays; // Hangi günler aktif (0-6: Pazar-Cumartesi)

  @HiveField(8)
  bool soundEnabled; // Ses açık mı?

  @HiveField(9)
  bool vibrationEnabled; // Titreşim açık mı?

  NotificationSettings({
    this.isEnabled = true,
    this.intervalHours = 2,
    this.startHour = 7,
    this.endHour = 22,
    this.morningEnabled = true,
    this.afternoonEnabled = true,
    this.eveningEnabled = true,
    this.selectedDays = const [1, 2, 3, 4, 5, 6, 7], // Tüm günler
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  /// JSON'dan model oluştur
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      isEnabled: json['isEnabled'] ?? true,
      intervalHours: json['intervalHours'] ?? 2,
      startHour: json['startHour'] ?? 7,
      endHour: json['endHour'] ?? 22,
      morningEnabled: json['morningEnabled'] ?? true,
      afternoonEnabled: json['afternoonEnabled'] ?? true,
      eveningEnabled: json['eveningEnabled'] ?? true,
      selectedDays: List<int>.from(
        json['selectedDays'] ?? [1, 2, 3, 4, 5, 6, 7],
      ),
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'intervalHours': intervalHours,
      'startHour': startHour,
      'endHour': endHour,
      'morningEnabled': morningEnabled,
      'afternoonEnabled': afternoonEnabled,
      'eveningEnabled': eveningEnabled,
      'selectedDays': selectedDays,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  /// Kopya oluştur
  NotificationSettings copyWith({
    bool? isEnabled,
    int? intervalHours,
    int? startHour,
    int? endHour,
    bool? morningEnabled,
    bool? afternoonEnabled,
    bool? eveningEnabled,
    List<int>? selectedDays,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      intervalHours: intervalHours ?? this.intervalHours,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      morningEnabled: morningEnabled ?? this.morningEnabled,
      afternoonEnabled: afternoonEnabled ?? this.afternoonEnabled,
      eveningEnabled: eveningEnabled ?? this.eveningEnabled,
      selectedDays: selectedDays ?? this.selectedDays,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  String toString() {
    return 'NotificationSettings(isEnabled: $isEnabled, intervalHours: $intervalHours, startHour: $startHour, endHour: $endHour)';
  }
}
