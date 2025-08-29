import 'app_localizations.dart';

/// Türkçe lokalizasyon
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  // Genel
  @override
  String get next => 'Devam Et';
  
  @override
  String get back => 'Geri';
  
  @override
  String get save => 'Kaydet';
  
  @override
  String get cancel => 'İptal';
  
  @override
  String get done => 'Tamam';
  
  @override
  String get loading => 'Yükleniyor...';
  
  @override
  String get error => 'Hata';

  // Onboarding - Ağırlık
  @override
  String get weightSelectTitle => 'Ağırlığınızı seçin';
  
  @override
  String get weightSelectSubtitle => 'Su ihtiyacınızı hesaplamak için ağırlığınızı belirtin';
  
  @override
  String get unitKg => 'kg';
  
  @override
  String get unitLb => 'lb';

  // Onboarding - Boy
  @override
  String get heightSelectTitle => 'Boyunuzu seçin';
  
  @override
  String get heightSelectSubtitle => 'Vücut kitle indeksinizi hesaplamak için boyunuzu belirtin';
  
  @override
  String get unitCm => 'cm';
  
  @override
  String get unitFtIn => 'ft, inç';

  // Onboarding - Cinsiyet
  @override
  String get genderSelectTitle => 'Cinsiyetinizi seçin';
  
  @override
  String get genderSelectSubtitle => 'Su ihtiyacınızı daha doğru hesaplamak için';
  
  @override
  String get genderMale => 'Erkek';
  
  @override
  String get genderFemale => 'Kadın';
  
  @override
  String get genderUndisclosed => 'Belirtmek istemiyorum';

  // Onboarding - Aktivite
  @override
  String get activitySelectTitle => 'Aktivite seviyenizi seçin';
  
  @override
  String get activitySelectSubtitle => 'Günlük aktivite düzeyinize göre su ihtiyacınızı hesaplayacağız';
  
  @override
  String get activityLow => 'Düşük (Masa başı)';
  
  @override
  String get activityMedium => 'Orta (Aktif iş / haftada 1-3 gün spor)';
  
  @override
  String get activityHigh => 'Yüksek (Ağır iş / haftada 3+ gün spor)';

  // Onboarding - Hedefler
  @override
  String get goalsSelectTitle => 'Hedeflerinizi seçin';
  
  @override
  String get goalsSelectSubtitle => 'Size özel motivasyon mesajları ve ipuçları için (opsiyonel)';
  
  @override
  String get goalHydration => 'Daha fazla su iç';
  
  @override
  String get goalWeightLoss => 'Ağırlığı azalt';
  
  @override
  String get goalSkinHealth => 'Cilt durumunu iyileştir';
  
  @override
  String get goalHealthyLifestyle => 'Sağlıklı yaşam tarzı';
  
  @override
  String get goalDigestion => 'Sindirimi iyileştir';

  // Onboarding - Sebze
  @override
  String get veggiesTitle => 'Sebze ve meyve tüketiminiz';
  
  @override
  String get veggiesSubtitle => 'Sebze ve meyveler doğal hidrasyon sağlar';
  
  @override
  String get veggiesRare => 'Nadiren';
  
  @override
  String get veggiesDaily => 'Düzenli olarak';
  
  @override
  String get veggiesFrequent => 'Sıklıkla';

  // Onboarding - Şekerli içecek
  @override
  String get sugaryTitle => 'Şekerli içecek tüketiminiz';
  
  @override
  String get sugarySubtitle => 'Şekerli içecekler dehidrasyon yapar ve daha fazla su gerektirir';
  
  @override
  String get sugaryAlmostNever => 'Neredeyse hiç';
  
  @override
  String get sugaryRare => 'Nadiren';
  
  @override
  String get sugaryDaily => 'Düzenli olarak';
  
  @override
  String get sugaryFrequent => 'Sıklıkla';

  // Onboarding - Özet
  @override
  String get summaryTitle => 'Profiliniz hazır!';
  
  @override
  String get summarySubtitle => 'Size özel hesaplanan günlük su hedefiniz';
  
  @override
  String get dailyGoalResult => 'Günlük Su Hedefiniz';
  
  @override
  String get saveAndStart => 'Kaydet ve Başla';

  // BMI
  @override
  String get bmiTitle => 'Vücut Kitle İndeksi (BMI)';
  
  @override
  String get bmiUnderweight => 'Zayıf';
  
  @override
  String get bmiNormal => 'Normal';
  
  @override
  String get bmiOverweight => 'Fazla kilolu';
  
  @override
  String get bmiObese => 'Obez';

  // Validasyon mesajları
  @override
  String get validationWeightRange => 'Ağırlık 30-200 kg arasında olmalıdır';
  
  @override
  String get validationHeightRange => 'Boy 120-220 cm arasında olmalıdır';
  
  @override
  String get validationRequired => 'Bu alan zorunludur';

  // Bilgi mesajları
  @override
  String get infoPrivacy => 'Bu bilgi sadece su ihtiyacınızı hesaplamak için kullanılır ve gizli tutulur.';
  
  @override
  String get infoActivity => 'Aktivite seviyeniz su ihtiyacınızı etkiler. Daha aktif yaşam tarzı daha fazla su gerektirir.';
  
  @override
  String get infoVeggies => 'Sebze ve meyveler doğal su içeriği sayesinde günlük su ihtiyacınızı azaltır.';
  
  @override
  String get infoSugary => 'Şekerli içecekler vücudunuzun su dengesini bozar ve daha fazla su içmenizi gerektirir.';
  
  @override
  String get infoGoals => 'Seçtiğiniz hedeflere göre size özel motivasyon mesajları ve sağlık ipuçları göndereceğiz.';

  // Başarı mesajları
  @override
  String get successProfileSaved => 'Profiliniz başarıyla kaydedildi! 🎉';
  
  @override
  String get successOnboardingComplete => 'Onboarding tamamlandı';

  // Hata mesajları
  @override
  String get errorGeneral => 'Bir hata oluştu';
  
  @override
  String get errorNetwork => 'İnternet bağlantısı hatası';
  
  @override
  String get errorSaving => 'Kaydetme hatası';

  // Profil sistemi
  @override
  String get profileSettings => 'Ayarlar';
  
  @override
  String get profileEdit => 'Profili düzenle';
  
  @override
  String get profileDailyNeed => 'Günlük ihtiyaç';
  
  @override
  String get profileNotifications => 'Bildirimler';
  
  @override
  String get profileFriends => 'Arkadaşlar';
  
  @override
  String get profileAchievements => 'Başarılar';
  
  @override
  String get profileNotificationStatusOn => 'Açık';
  
  @override
  String get profileNotificationStatusOff => 'Kapalı';
  
  @override
  String get profileFriendsAdd => 'Ekle';

  // Su ihtiyacı detay ekranı
  @override
  String get waterNeedPersonalAssistant => 'Suu — kişisel asistanın';
  
  @override
  String get waterNeedCalculating => 'Su ihtiyacınızı hesaplıyor';
  
  @override
  String get waterNeedDailyGoal => 'Günlük Su Hedefiniz';
  
  @override
  String get waterNeedUpdateInfo => 'Bilgileri Güncelle';
  
  @override
  String get waterNeedHowCalculated => 'Nasıl Hesaplandı?';
  
  @override
  String get waterNeedFormulaExplanation => 'Bu hedef, ağırlığınız, yaşınız, cinsiyet ve aktivite seviyeniz göz önünde bulundurularak bilimsel formüllerle hesaplanmıştır.';
  
  @override
  String get waterNeedGoodToKnow => 'Bilmeniz Gerekenler';
  
  @override
  String get waterNeedPersonalizedTitle => 'Kişiselleştirilmiş Hesaplama';
  
  @override
  String get waterNeedPersonalizedDesc => 'Hedefiniz yaş, kilo, boy, cinsiyet ve aktivite seviyenize göre hesaplanır.';
  
  @override
  String get waterNeedDailyUpdateTitle => 'Günlük Güncelleme';
  
  @override
  String get waterNeedDailyUpdateDesc => 'Bilgilerinizi güncellerseniz hedefiniz otomatik olarak yeniden hesaplanır.';
  
  @override
  String get waterNeedScientificTitle => 'Bilimsel Formül';
  
  @override
  String get waterNeedScientificDesc => 'Hesaplama uluslararası sağlık kuruluşlarının önerilerine dayanır.';

  // Faktörler
  @override
  String get factorWeight => 'Ağırlık';
  
  @override
  String get factorAge => 'Yaş';
  
  @override
  String get factorGender => 'Cinsiyet';
  
  @override
  String get factorActivity => 'Aktivite';

  // Geçici mesajlar
  @override
  String get comingSoonNotifications => 'Bildirimler ekranı yakında eklenecek';
  
  @override
  String get comingSoonFriends => 'Arkadaşlar özelliği yakında eklenecek';
}
