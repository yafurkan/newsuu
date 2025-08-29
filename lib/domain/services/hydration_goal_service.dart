import '../../data/models/user_profile.dart';
import '../../data/models/hydration_factors.dart';
import '../../core/utils/debug_logger.dart';

/// Hidrasyon hedef hesaplama servisi
/// Tek sorumluluk: Kullanıcı profiline göre günlük su hedefini hesaplar
class HydrationGoalService {
  /// Günlük su hedefini hesapla (ml cinsinden)
  static int computeDailyGoalMl(UserProfile profile) {
    try {
      // Temel hesaplama: ağırlık * temel katsayı
      double ml = profile.weightKg * HydrationFactors.baseMlPerKg;
      
      DebugLogger.info(
        '📊 Temel hesaplama: ${profile.weightKg}kg * ${HydrationFactors.baseMlPerKg} = ${ml.toInt()}ml',
        tag: 'HYDRATION_GOAL',
      );
      
      // Aktivite seviyesi faktörü uygula
      final activityFactor = HydrationFactors.activityFactors[profile.activity.name] ?? 1.0;
      ml *= activityFactor;
      
      DebugLogger.info(
        '🏃 Aktivite faktörü (${profile.activity.name}): x${activityFactor} = ${ml.toInt()}ml',
        tag: 'HYDRATION_GOAL',
      );
      
      // Sebze ve meyve tüketimi düzeltmesi
      final veggieAdjustment = HydrationFactors.veggieAdjustments[profile.veggies.name] ?? 0.0;
      ml *= (1 + veggieAdjustment);
      
      DebugLogger.info(
        '🥬 Sebze düzeltmesi (${profile.veggies.name}): ${veggieAdjustment > 0 ? '+' : ''}${(veggieAdjustment * 100).toInt()}% = ${ml.toInt()}ml',
        tag: 'HYDRATION_GOAL',
      );
      
      // Şekerli içecek tüketimi düzeltmesi
      final sugaryAdjustment = HydrationFactors.sugaryAdjustments[profile.sugary.name] ?? 0.0;
      ml *= (1 + sugaryAdjustment);
      
      DebugLogger.info(
        '🥤 Şekerli içecek düzeltmesi (${profile.sugary.name}): ${sugaryAdjustment > 0 ? '+' : ''}${(sugaryAdjustment * 100).toInt()}% = ${ml.toInt()}ml',
        tag: 'HYDRATION_GOAL',
      );
      
      // Min-max sınırları uygula
      ml = ml.clamp(HydrationFactors.minMl, HydrationFactors.maxMl);
      
      // 50 ml'lik kademelere yuvarla (UI'de güzel görünür)
      final roundedMl = (ml / 50).round() * 50;
      
      DebugLogger.info(
        '🎯 Final hedef: ${roundedMl}ml (${UnitConversions.mlToL(roundedMl.toDouble()).toStringAsFixed(1)}L)',
        tag: 'HYDRATION_GOAL',
      );
      
      return roundedMl;
      
    } catch (e) {
      DebugLogger.info(
        '❌ Hedef hesaplama hatası: $e',
        tag: 'HYDRATION_GOAL',
      );
      
      // Hata durumunda güvenli varsayılan değer döndür
      return 2000; // 2L
    }
  }
  
  /// Hedef hesaplama detaylarını al (debug/analiz için)
  static Map<String, dynamic> getCalculationDetails(UserProfile profile) {
    final baseWater = profile.weightKg * HydrationFactors.baseMlPerKg;
    final activityFactor = HydrationFactors.activityFactors[profile.activity.name] ?? 1.0;
    final veggieAdjustment = HydrationFactors.veggieAdjustments[profile.veggies.name] ?? 0.0;
    final sugaryAdjustment = HydrationFactors.sugaryAdjustments[profile.sugary.name] ?? 0.0;
    
    final afterActivity = baseWater * activityFactor;
    final afterVeggies = afterActivity * (1 + veggieAdjustment);
    final afterSugary = afterVeggies * (1 + sugaryAdjustment);
    final clamped = afterSugary.clamp(HydrationFactors.minMl, HydrationFactors.maxMl);
    final final_result = (clamped / 50).round() * 50;
    
    return {
      'profile': {
        'weight_kg': profile.weightKg,
        'activity': profile.activity.name,
        'veggies': profile.veggies.name,
        'sugary': profile.sugary.name,
      },
      'calculation_steps': {
        'base_water_ml': baseWater.toInt(),
        'activity_factor': activityFactor,
        'after_activity_ml': afterActivity.toInt(),
        'veggie_adjustment': veggieAdjustment,
        'after_veggies_ml': afterVeggies.toInt(),
        'sugary_adjustment': sugaryAdjustment,
        'after_sugary_ml': afterSugary.toInt(),
        'clamped_ml': clamped.toInt(),
        'final_rounded_ml': final_result,
      },
      'factors_used': {
        'base_ml_per_kg': HydrationFactors.baseMlPerKg,
        'min_ml': HydrationFactors.minMl,
        'max_ml': HydrationFactors.maxMl,
      },
      'result': {
        'daily_goal_ml': final_result,
        'daily_goal_l': UnitConversions.mlToL(final_result.toDouble()),
      }
    };
  }
  
  /// Hedef değişikliğini kontrol et (eski profil vs yeni profil)
  static bool shouldUpdateGoal(UserProfile oldProfile, UserProfile newProfile) {
    return oldProfile.weightKg != newProfile.weightKg ||
           oldProfile.activity != newProfile.activity ||
           oldProfile.veggies != newProfile.veggies ||
           oldProfile.sugary != newProfile.sugary;
  }
  
  /// Hedef kategorisine göre önerilen günlük artış miktarı
  static int getRecommendedDailyIncrease(Set<String> goalIds) {
    if (goalIds.isEmpty) return 0;
    
    int totalIncrease = 0;
    
    // Her hedef için ek su miktarı öner
    if (goalIds.contains('weight_loss')) {
      totalIncrease += 250; // Kilo verme için ekstra 250ml
    }
    
    if (goalIds.contains('skin_health')) {
      totalIncrease += 200; // Cilt sağlığı için ekstra 200ml
    }
    
    if (goalIds.contains('digestion')) {
      totalIncrease += 150; // Sindirim için ekstra 150ml
    }
    
    if (goalIds.contains('hydration')) {
      totalIncrease += 300; // Genel hidrasyon için ekstra 300ml
    }
    
    // Maksimum 500ml ek artış
    return totalIncrease.clamp(0, 500);
  }
  
  /// Profil tamamlama yüzdesini hesapla
  static double getProfileCompletionPercentage(UserProfile profile) {
    int completedFields = 0;
    int totalFields = 8;
    
    if (profile.firstName.isNotEmpty) completedFields++;
    if (profile.lastName.isNotEmpty) completedFields++;
    if (profile.age > 0) completedFields++;
    if (profile.weightKg > 0) completedFields++;
    if (profile.heightCm > 0) completedFields++;
    if (profile.gender != Gender.undisclosed) completedFields++;
    if (profile.goals.isNotEmpty) completedFields++;
    if (profile.activity != ActivityLevel.medium) completedFields++; // Varsayılan değil ise
    
    return (completedFields / totalFields) * 100;
  }
  
  /// Hedef önerisi mesajı oluştur
  static String generateGoalSuggestionMessage(UserProfile profile) {
    final goalMl = computeDailyGoalMl(profile);
    final goalL = UnitConversions.mlToL(goalMl.toDouble());
    
    final messages = <String>[];
    
    // Temel mesaj
    messages.add('Günlük su hedefiniz: ${goalL.toStringAsFixed(1)}L');
    
    // Aktivite seviyesine göre mesaj
    switch (profile.activity) {
      case ActivityLevel.high:
        messages.add('Yüksek aktivite seviyeniz nedeniyle daha fazla su içmeniz öneriliyor.');
        break;
      case ActivityLevel.low:
        messages.add('Masa başı çalışıyorsanız, düzenli su içmeyi unutmayın.');
        break;
      default:
        break;
    }
    
    // Hedeflere göre özel mesajlar
    if (profile.goals.contains('weight_loss')) {
      messages.add('Kilo verme hedefiniz için su içmek metabolizmanızı hızlandırır.');
    }
    
    if (profile.goals.contains('skin_health')) {
      messages.add('Cilt sağlığınız için düzenli hidrasyon çok önemli.');
    }
    
    return messages.join(' ');
  }
}
