# Su Takip - Onboarding 2.0

Bu dokümantasyon, Su Takip uygulaması için geliştirilen yeni onboarding sistemini açıklar.

## 📋 Genel Bakış

Onboarding 2.0, kullanıcıların kişiselleştirilmiş su hedeflerini belirlemek için 8 adımlı bir süreç sunar:

1. **Ağırlık Seçimi** - kg/lb birim desteği ile
2. **Boy Seçimi** - cm/ft-inch birim desteği ile
3. **Cinsiyet Seçimi** - App Store uyumlu seçenekler
4. **Aktivite Seviyesi** - 3 seviye aktivite
5. **Hedefler** - Çoklu seçim destekli motivasyon hedefleri
6. **Sebze & Meyve Tüketimi** - Hidrasyon faktörü
7. **Şekerli İçecek Tüketimi** - Dehidrasyon faktörü
8. **Özet & Kaydetme** - Hesaplanan hedef ile profil özeti

## 🏗️ Mimari

### Dosya Yapısı

```
lib/
├── data/
│   └── models/
│       ├── user_profile.dart          # Genişletilmiş kullanıcı profil modeli
│       └── hydration_factors.dart     # Birim dönüşümleri ve faktörler
├── domain/
│   └── services/
│       └── hydration_goal_service.dart # Su hedefi hesaplama servisi
├── presentation/
│   ├── providers/
│   │   └── onboarding_provider.dart   # Onboarding state yönetimi
│   ├── onboarding/
│   │   ├── widgets/                   # Yeniden kullanılabilir bileşenler
│   │   │   ├── segmented_unit_toggle.dart
│   │   │   ├── ruler_picker.dart
│   │   │   ├── goal_chip.dart
│   │   │   └── step_progress.dart
│   │   └── screens/                   # Onboarding ekranları
│   │       ├── ob_weight_screen.dart
│   │       ├── ob_height_screen.dart
│   │       ├── ob_gender_screen.dart
│   │       ├── ob_activity_screen.dart
│   │       ├── ob_goals_screen.dart
│   │       ├── ob_veggies_screen.dart
│   │       ├── ob_sugary_screen.dart
│   │       ├── ob_summary_screen.dart
│   │       └── onboarding_navigator.dart
└── l10n/                              # Lokalizasyon dosyaları
    ├── app_localizations.dart
    ├── app_localizations_tr.dart
    └── app_localizations_en.dart
```

## 🧮 Su Hedefi Hesaplama Formülü

### Temel Formül
```
Günlük Su İhtiyacı (ml) = Ağırlık (kg) × 35 ml/kg
```

### Faktörler
- **Aktivite Seviyesi:**
  - Düşük: ×1.00
  - Orta: ×1.12 (+%12)
  - Yüksek: ×1.25 (+%25)

- **Sebze & Meyve Tüketimi:**
  - Nadiren: %0 (etkisiz)
  - Düzenli: -%2 (azaltır)
  - Sıklıkla: -%5 (azaltır)

- **Şekerli İçecek Tüketimi:**
  - Neredeyse hiç: %0 (etkisiz)
  - Nadiren: +%4 (artırır)
  - Düzenli: +%8 (artırır)
  - Sıklıkla: +%12 (artırır)

### Sınırlar
- **Minimum:** 1.5L (1500ml)
- **Maksimum:** 6.0L (6000ml)
- **Yuvarlama:** 50ml kademeli

## 🎨 UI/UX Özellikleri

### Yeniden Kullanılabilir Bileşenler

#### SegmentedUnitToggle
- Birim seçimi için animasyonlu toggle
- Haptic feedback desteği
- Dark/Light tema uyumlu

#### RulerPicker
- Yatay kaydırmalı değer seçici
- Custom painter ile performanslı çizim
- Haptic feedback ile değer değişimi
- Dual picker desteği (feet/inches için)

#### GoalChip
- Animasyonlu seçim chip'i
- Scale ve glow efektleri
- Multi-select desteği

#### StepProgress
- Çoklu stil desteği (bar, dot, line)
- Animasyonlu geçişler
- Özelleştirilebilir renkler

### Animasyonlar
- **Geçiş Animasyonları:** 200ms easeInOut
- **Scale Efektleri:** Seçim sırasında 1.05x büyütme
- **Glow Efektleri:** Primary color ile yumuşak gölge
- **Haptic Feedback:** Seçim ve değer değişimlerinde

## 🌍 Lokalizasyon

### Desteklenen Diller
- **Türkçe (tr)** - Ana dil
- **İngilizce (en)** - İkincil dil

### Kullanım
```dart
// Context extension ile kolay erişim
Text(context.l10n.weightSelectTitle)

// Geleneksel yöntem
Text(AppLocalizations.of(context).weightSelectTitle)
```

## 🔧 Entegrasyon

### Temel Kullanım
```dart
// Basit onboarding navigator
OnboardingNavigator()

// Wrapper ile koşullu gösterim
OnboardingWrapper(
  forceOnboarding: true,
  child: HomeScreen(),
)

// Tam entegrasyon
OnboardingIntegratedApp(
  homeScreen: HomeScreen(),
  onOnboardingComplete: () {
    // Tamamlama callback'i
  },
)
```

### Provider Entegrasyonu
```dart
// Provider'ı uygulamaya ekle
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => OnboardingProvider()),
    // Diğer provider'lar...
  ],
  child: MyApp(),
)
```

## 📊 Veri Modeli

### UserProfile
```dart
class UserProfile {
  final double weightKg;        // Her zaman KG
  final double heightCm;        // Her zaman CM
  final Gender gender;          // male, female, undisclosed
  final ActivityLevel activity; // low, medium, high
  final Set<String> goals;      // Hedef ID'leri
  final VeggieFreq veggies;     // rare, daily, frequent
  final SugaryFreq sugary;      // almostNever, rare, daily, frequent
  final String? unitPreferenceWeight; // UI tercihi
  final String? unitPreferenceHeight; // UI tercihi
  final double dailyGoalMl;     // Hesaplanan hedef
  // ... diğer alanlar
}
```

## 🧪 Test Senaryoları

### Fonksiyonel Testler
- [ ] Birim dönüşümleri doğru çalışıyor
- [ ] RulerPicker akıcı kaydırma
- [ ] Haptic feedback aktif
- [ ] Validasyon kuralları çalışıyor
- [ ] Hedef hesaplama doğru
- [ ] Profil kaydetme başarılı
- [ ] Offline tolerant çalışma

### UI/UX Testler
- [ ] Dark/Light tema uyumu
- [ ] Animasyonlar akıcı (60fps)
- [ ] Erişilebilirlik etiketleri
- [ ] Minimum dokunma alanı (44px)
- [ ] Responsive tasarım

### Platform Testleri
- [ ] iOS cihazlarda çalışma
- [ ] Android cihazlarda çalışma
- [ ] Farklı ekran boyutları
- [ ] Farklı dil ayarları

## 🚀 Gelecek Geliştirmeler

### Planlanan Özellikler
- [ ] Remote Config ile faktör güncelleme
- [ ] A/B testing desteği
- [ ] Gelişmiş analytics
- [ ] Sosyal medya entegrasyonu
- [ ] Wearable cihaz desteği

### Optimizasyonlar
- [ ] Performans iyileştirmeleri
- [ ] Memory usage optimizasyonu
- [ ] Battery usage optimizasyonu
- [ ] Network efficiency

## 📝 Notlar

### Önemli Kısıtlar
- Mevcut kullanıcı profili yapısı korunmuştur
- Firebase/Firestore entegrasyonu mevcut API'yi kullanır
- Provider pattern mevcut yapıyla uyumludur
- Lokalizasyon sistemi genişletilebilir

### Geliştirici Notları
- Tüm yeni bileşenler yeniden kullanılabilir tasarlanmıştır
- Kod Türkçe yorumlarla açıklanmıştır
- Debug logging HydrationGoalService'te mevcuttur
- Error handling offline senaryoları destekler

## 🤝 Katkıda Bulunma

Yeni özellik eklerken:
1. Mevcut mimariyi koruyun
2. Yeniden kullanılabilir bileşenler oluşturun
3. Türkçe yorumlar ekleyin
4. Lokalizasyon desteği sağlayın
5. Test senaryolarını güncelleyin

---

**Geliştirici:** Cline AI Assistant  
**Versiyon:** 2.0  
**Tarih:** Ağustos 2025
