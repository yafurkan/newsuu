import 'package:hive/hive.dart';

part 'water_intake_model.g.dart';

/// Su alımı bilgilerini tutan model sınıfı
@HiveType(typeId: 1)
class WaterIntakeModel extends HiveObject {
  @HiveField(0)
  double amount; // ml

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  String? note; // Opsiyonel not

  WaterIntakeModel({required this.amount, required this.timestamp, this.note});

  /// JSON'dan model oluştur
  factory WaterIntakeModel.fromJson(Map<String, dynamic> json) {
    return WaterIntakeModel(
      amount: json['amount']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
      note: json['note'],
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  /// Kopya oluştur
  WaterIntakeModel copyWith({
    double? amount,
    DateTime? timestamp,
    String? note,
  }) {
    return WaterIntakeModel(
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'WaterIntakeModel(amount: $amount, timestamp: $timestamp, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WaterIntakeModel &&
        other.amount == amount &&
        other.timestamp == timestamp &&
        other.note == note;
  }

  @override
  int get hashCode {
    return amount.hashCode ^ timestamp.hashCode ^ note.hashCode;
  }
}
