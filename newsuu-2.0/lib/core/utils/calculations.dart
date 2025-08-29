/// Su ihtiyacı hesaplama ve yardımcı fonksiyonlar
class WaterCalculations {
  /// Günlük su ihtiyacını hesaplar
  ///
  /// Formula: Temel ihtiyaç (35ml x kg) + yaş faktörü + cinsiyet faktörü + aktivite faktörü
  static double calculateDailyWaterNeed({
    required double weight,
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    // Temel hesaplama: 35ml x kilogram
    double baseNeed = weight * 35;

    // Yaş faktörü
    if (age < 30) {
      baseNeed *= 1.1; // Genç yaşta metabolizma daha hızlı
    } else if (age > 65) {
      baseNeed *= 0.9; // Yaşlılarda su ihtiyacı biraz azalır
    }

    // Cinsiyet faktörü
    if (gender.toLowerCase() == 'male' || gender.toLowerCase() == 'erkek') {
      baseNeed *= 1.1; // Erkeklerin su ihtiyacı %10 daha fazla
    }

    // Aktivite seviyesi faktörü
    switch (activityLevel.toLowerCase()) {
      case 'low':
      case 'düşük':
        baseNeed *= 1.0; // Temel seviye
        break;
      case 'medium':
      case 'orta':
        baseNeed *= 1.2; // %20 artış
        break;
      case 'high':
      case 'yüksek':
        baseNeed *= 1.4; // %40 artış
        break;
      default:
        baseNeed *= 1.0;
    }

    // Minimum 1500ml, maksimum 4000ml sınırları
    if (baseNeed < 1500) baseNeed = 1500;
    if (baseNeed > 4000) baseNeed = 4000;

    return baseNeed.roundToDouble();
  }

  /// Hedefin yüzde kaçına ulaşıldığını hesaplar
  static double calculateProgress(double currentIntake, double dailyGoal) {
    if (dailyGoal <= 0) return 0.0;
    double progress = (currentIntake / dailyGoal) * 100;
    return progress > 100 ? 100.0 : progress;
  }

  /// Hedefe ulaşmak için gereken su miktarını hesaplar
  static double calculateRemainingAmount(
    double currentIntake,
    double dailyGoal,
  ) {
    double remaining = dailyGoal - currentIntake;
    return remaining > 0 ? remaining : 0.0;
  }

  /// Su miktarını uygun birime çevirir (ml veya L)
  static String formatWaterAmount(double amount) {
    if (amount >= 1000) {
      double liters = amount / 1000;
      return '${liters.toStringAsFixed(liters.truncateToDouble() == liters ? 0 : 1)} L';
    } else {
      return '${amount.toInt()} ml';
    }
  }

  /// Bardak sayısına çevirir (1 bardak = 250ml)
  static double convertToGlasses(double amount) {
    return amount / 250;
  }

  /// Bardak sayısını ml'ye çevirir
  static double convertFromGlasses(double glasses) {
    return glasses * 250;
  }

  /// Su içme sıklığını hesaplar (günde kaç kez içmeli)
  static int calculateFrequency(double dailyGoal, double averageGlassSize) {
    return (dailyGoal / averageGlassSize).ceil();
  }

  /// Saatlik hatırlatma aralığını hesaplar
  static int calculateReminderInterval(double dailyGoal) {
    // Günlük hedef bazında hatırlatma aralığı (saat)
    if (dailyGoal <= 2000) return 2; // 2 saatte bir
    if (dailyGoal <= 3000) return 1; // 1 saatte bir
    return 1; // Yoğun aktivite için 1 saatte bir
  }

  /// BMI hesaplar (ek bilgi için)
  static double calculateBMI(double weight, double height) {
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// BMI kategorisini döndürür
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Zayıf';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Fazla Kilolu';
    return 'Obez';
  }

  /// Günlük su alımının sağlık açısından değerlendirmesini yapar
  static String evaluateIntake(double currentIntake, double dailyGoal) {
    double progress = calculateProgress(currentIntake, dailyGoal);

    if (progress >= 100) {
      return 'Mükemmel! Günlük hedefinizi tamamladınız.';
    } else if (progress >= 80) {
      return 'Harika! Hedefinize çok yaklaştınız.';
    } else if (progress >= 60) {
      return 'İyi gidiyorsunuz! Biraz daha devam edin.';
    } else if (progress >= 40) {
      return 'Daha fazla su içmeye odaklanın.';
    } else if (progress >= 20) {
      return 'Su içmeyi unutmayın! Sağlığınız için önemli.';
    } else {
      return 'Bugün çok az su içtiniz. Hemen başlayın!';
    }
  }
}
