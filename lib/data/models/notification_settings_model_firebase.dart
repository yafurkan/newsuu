/// Bildirim ayarları model sınıfı (Firebase entegreli)
class NotificationSettings {
  bool isEnabled; // Bildirimler açık mı?
  int intervalHours; // Bildirim sıklığı (saat)
  int startHour; // Başlangıç saati
  int endHour; // Bitiş saati
  bool morningEnabled; // Sabah bildirimleri
  bool afternoonEnabled; // Öğlen bildirimleri
  bool eveningEnabled; // Akşam bildirimleri
  List<int> selectedDays; // Hangi günler aktif (0-6: Pazar-Cumartesi)
  bool soundEnabled; // Ses açık mı?
  bool vibrationEnabled; // Titreşim açık mı?
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
    this.intervalEnabled = false,
  }) : selectedDays =
           selectedDays ?? [1, 2, 3, 4, 5, 6, 7]; // Varsayılan: Pazartesi-Pazar

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
