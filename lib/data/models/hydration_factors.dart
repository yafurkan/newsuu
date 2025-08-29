/// Birim dönüşüm yardımcı fonksiyonları
class UnitConversions {
  /// Pound'dan kilogram'a dönüştürme
  static double lbToKg(double lb) => lb * 0.45359237;
  
  /// Kilogram'dan pound'a dönüştürme
  static double kgToLb(double kg) => kg / 0.45359237;
  
  /// Santimetre'den feet'e dönüştürme
  static double cmToFeet(double cm) => cm / 30.48;
  
  /// Feet ve inch'den santimetre'ye dönüştürme
  static double feetInchesToCm(int ft, int inch) => ft * 30.48 + inch * 2.54;
  
  /// Santimetre'den feet ve inch'e dönüştürme
  static Map<String, int> cmToFeetInches(double cm) {
    final totalInches = cm / 2.54;
    final feet = (totalInches / 12).floor();
    final inches = (totalInches % 12).round();
    return {'feet': feet, 'inches': inches};
  }
  
  /// Mililitre'den litre'ye dönüştürme
  static double mlToL(double ml) => ml / 1000;
  
  /// Litre'den mililitre'ye dönüştürme
  static double lToMl(double l) => l * 1000;
}

/// Hidrasyon hedef hesaplama katsayıları
class HydrationFactors {
  /// Temel su ihtiyacı (ml/kg)
  static const double baseMlPerKg = 35.0;
  
  /// Minimum günlük su miktarı (ml)
  static const double minMl = 1500.0;
  
  /// Maksimum günlük su miktarı (ml)
  static const double maxMl = 6000.0;
  
  /// Aktivite seviyesi çarpanları
  static const Map<String, double> activityFactors = {
    'low': 1.00,    // Masa başı
    'medium': 1.12, // +%12
    'high': 1.25,   // +%25
  };
  
  /// Sebze ve meyve tüketimi düzeltme faktörleri (negatif = azaltır)
  static const Map<String, double> veggieAdjustments = {
    'rare': 0.00,     // Etkisiz
    'daily': -0.02,   // -%2 (hidratasyon katkısı)
    'frequent': -0.05, // -%5
  };
  
  /// Şekerli içecek tüketimi düzeltme faktörleri (pozitif = artırır)
  static const Map<String, double> sugaryAdjustments = {
    'almostNever': 0.00, // Etkisiz
    'rare': 0.04,        // +%4
    'daily': 0.08,       // +%8
    'frequent': 0.12,    // +%12
  };
  
  /// Yaş faktörleri (opsiyonel, gelecekte kullanılabilir)
  static const Map<String, double> ageFactors = {
    'young': 1.05,    // 18-30 yaş
    'adult': 1.00,    // 31-50 yaş
    'middle': 0.98,   // 51-65 yaş
    'senior': 0.95,   // 65+ yaş
  };
  
  /// Cinsiyet faktörleri (opsiyonel, gelecekte kullanılabilir)
  static const Map<String, double> genderFactors = {
    'male': 1.02,
    'female': 0.98,
    'undisclosed': 1.00,
  };
}

/// Hedef kategorileri ve açıklamaları
class GoalCategories {
  static const Map<String, Map<String, String>> goals = {
    'hydration': {
      'title': 'Daha fazla su iç',
      'description': 'Günlük su tüketiminizi artırın',
      'icon': '💧',
    },
    'weight_loss': {
      'title': 'Ağırlığı azalt',
      'description': 'Sağlıklı kilo verme hedefi',
      'icon': '⚖️',
    },
    'skin_health': {
      'title': 'Cilt durumunu iyileştir',
      'description': 'Cildinizin nem dengesini koruyun',
      'icon': '✨',
    },
    'healthy_lifestyle': {
      'title': 'Sağlıklı yaşam tarzı',
      'description': 'Genel sağlık ve wellness',
      'icon': '🌱',
    },
    'digestion': {
      'title': 'Sindirimi iyileştir',
      'description': 'Sindirim sisteminizi destekleyin',
      'icon': '🌿',
    },
  };
  
  /// Hedef ID'sinden bilgi alma
  static Map<String, String>? getGoalInfo(String goalId) {
    return goals[goalId];
  }
  
  /// Tüm hedef ID'lerini alma
  static List<String> getAllGoalIds() {
    return goals.keys.toList();
  }
}

/// Motivasyon mesajları (hedeflere göre)
class MotivationMessages {
  static const Map<String, List<String>> messagesByGoal = {
    'hydration': [
      'Su içmeyi unutma! 💧',
      'Vücudun suya ihtiyacı var! 🌊',
      'Hidrasyon zamanı! ✨',
    ],
    'weight_loss': [
      'Su içmek metabolizmanı hızlandırır! ⚡',
      'Her yudum seni hedefe yaklaştırır! 🎯',
      'Su, doğal detoks! 🌿',
    ],
    'skin_health': [
      'Cildin için su iç! ✨',
      'Parlak cilt için hidrasyon şart! 💎',
      'Su, doğal güzellik sırrı! 🌸',
    ],
    'healthy_lifestyle': [
      'Sağlıklı yaşam su ile başlar! 🌱',
      'Vücudun teşekkür ediyor! 💚',
      'Her yudum sağlık! 🍃',
    ],
    'digestion': [
      'Sindirim için su şart! 🌿',
      'Miden rahat etsin! 💚',
      'Su, doğal sindirim yardımcısı! 🌊',
    ],
  };
  
  /// Rastgele motivasyon mesajı alma
  static String getRandomMessage(Set<String> goalIds) {
    if (goalIds.isEmpty) {
      return 'Su içmeyi unutma! 💧';
    }
    
    final allMessages = <String>[];
    for (final goalId in goalIds) {
      final messages = messagesByGoal[goalId];
      if (messages != null) {
        allMessages.addAll(messages);
      }
    }
    
    if (allMessages.isEmpty) {
      return 'Su içmeyi unutma! 💧';
    }
    
    allMessages.shuffle();
    return allMessages.first;
  }
}
