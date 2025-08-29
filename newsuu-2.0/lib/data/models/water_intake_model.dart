/// Su alımı bilgilerini tutan model sınıfı (Firebase entegreli)
class WaterIntakeModel {
  String id; // Unique identifier
  double amount; // ml
  DateTime timestamp;
  String? note; // Opsiyonel not

  WaterIntakeModel({
    required this.id,
    required this.amount,
    required this.timestamp,
    this.note,
  });

  /// JSON'dan model oluştur
  factory WaterIntakeModel.fromJson(Map<String, dynamic> json) {
    return WaterIntakeModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: json['amount']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
      note: json['note'],
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  /// Kopya oluştur
  WaterIntakeModel copyWith({
    String? id,
    double? amount,
    DateTime? timestamp,
    String? note,
  }) {
    return WaterIntakeModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'WaterIntakeModel(id: $id, amount: $amount, timestamp: $timestamp, note: $note)';
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
