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

  @HiveField(10)
  bool intervalEnabled; // Sıklık bazlı bildirimler açık mı?

  NotificationSettings({
    this.isEnabled = false, // Başlangıçta bildirim sıklığı KAPALI
    this.intervalHours = 2,
    this.startHour = 7,
    this.endHour = 22,
    this.morningEnabled = true, // Özel zaman dilimleri AÇIK (günde 3 bildirim)
    this.afternoonEnabled = true,
    this.eveningEnabled = true,
    List<int>? selectedDays,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.intervalEnabled = false, // Sıklık bazlı bildirimler başlangıçta KAPALI
  }) : selectedDays = List.from(selectedDays ?? [1, 2, 3, 4, 5, 6, 7]);

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
      intervalEnabled: json['intervalEnabled'] ?? false,
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
      'intervalEnabled': intervalEnabled,
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
    bool? intervalEnabled,
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
      intervalEnabled: intervalEnabled ?? this.intervalEnabled,
    );
  }

  @override
  String toString() {
    return 'NotificationSettings(isEnabled: $isEnabled, intervalHours: $intervalHours, startHour: $startHour, endHour: $endHour)';
  }
}
