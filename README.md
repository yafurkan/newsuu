# 💧 Su Takip Uygulaması

Modern ve kullanıcı dostu su tüketimi takip uygulaması. Flutter ile geliştirilmiş, Firebase backend'li.

## 🚀 Özellikler

- ✅ Günlük su tüketimi takibi
- 📊 Detaylı istatistikler ve grafikler
- 🏆 Başarı rozetleri sistemi
- 🔔 Akıllı hatırlatma bildirimleri
- 🌤️ Hava durumu entegrasyonu
- 👤 Kullanıcı profil yönetimi
- 🔄 Bulut senkronizasyonu
- 📱 Çoklu platform desteği (Android, iOS, Web, Windows)

## 🔒 Güvenlik

Bu proje güvenlik-öncelikli yaklaşımla geliştirilmiştir:

### ✅ Güvenlik Özellikleri
- 🔐 Environment variables ile API anahtarı koruması
- 🛡️ Otomatik güvenlik doğrulaması
- 🚫 Hassas bilgilerin Git'e commit edilmemesi
- 📋 Kapsamlı güvenlik rehberi
- 🔍 Runtime güvenlik kontrolleri

### 🔧 Kurulum Öncesi Güvenlik Ayarları

1. **Environment Variables Ayarlayın:**
   ```bash
   # .env.example dosyasını .env olarak kopyalayın
   cp .env.example .env
   
   # Firebase Console'dan gerçek API anahtarlarınızı alın
   # .env dosyasındaki placeholder'ları gerçek değerlerle değiştirin
   ```

2. **Firebase Konfigürasyonu:**
   - Firebase Console'da yeni proje oluşturun
   - Android/iOS/Web uygulamaları ekleyin
   - API anahtarlarını `.env` dosyasına ekleyin

3. **Güvenlik Kontrolü:**
   ```bash
   # Uygulama başlangıcında otomatik güvenlik kontrolü yapılır
   flutter run
   ```

## 📦 Kurulum

### Gereksinimler
- Flutter SDK (3.8.1+)
- Dart SDK
- Firebase hesabı
- Android Studio / VS Code

### Adımlar

1. **Projeyi klonlayın:**
   ```bash
   git clone https://github.com/your-username/su_takip.git
   cd su_takip
   ```

2. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```

3. **Environment variables ayarlayın:**
   ```bash
   cp .env.example .env
   # .env dosyasını gerçek API anahtarlarınızla düzenleyin
   ```

4. **Firebase kurulumu:**
   ```bash
   # Firebase CLI kurulumu
   npm install -g firebase-tools
   
   # Firebase'e giriş yapın
   firebase login
   
   # Projeyi Firebase'e bağlayın
   firebase use --add
   ```

5. **Uygulamayı çalıştırın:**
   ```bash
   flutter run
   ```

## 🏗️ Proje Yapısı

```
lib/
├── core/                    # Temel altyapı
│   ├── config/             # Konfigürasyon yönetimi
│   ├── security/           # Güvenlik servisleri
│   ├── services/           # Temel servisler
│   └── utils/              # Yardımcı araçlar
├── data/                   # Veri katmanı
│   ├── models/             # Veri modelleri
│   ├── repositories/       # Repository pattern
│   └── services/           # Veri servisleri
├── presentation/           # UI katmanı
│   ├── providers/          # State management
│   ├── screens/            # Ekranlar
│   └── widgets/            # UI bileşenleri
└── main.dart              # Uygulama giriş noktası
```

## 🔧 Geliştirme

### Kod Kalitesi
```bash
# Kod analizi
flutter analyze

# Testleri çalıştır
flutter test

# Kod formatla
dart format .
```

### Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

## 📱 Platform Desteği

| Platform | Durum | Notlar |
|----------|-------|--------|
| Android  | ✅ Destekleniyor | API 21+ |
| iOS      | ✅ Destekleniyor | iOS 12+ |
| Web      | ✅ Destekleniyor | Modern tarayıcılar |
| Windows  | ✅ Destekleniyor | Windows 10+ |
| macOS    | 🔄 Geliştiriliyor | - |
| Linux    | 🔄 Geliştiriliyor | - |

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

### Güvenlik Kuralları
- Asla gerçek API anahtarlarını commit etmeyin
- `.env` dosyasını Git'e eklemeyin
- Güvenlik rehberini takip edin (`SECURITY_GUIDE.md`)

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

## 📞 İletişim

- **Geliştirici:** [Your Name]
- **Email:** your.email@example.com
- **GitHub:** [@your-username](https://github.com/your-username)

## 🙏 Teşekkürler

- Flutter ekibine harika framework için
- Firebase ekibine güçlü backend servisleri için
- Açık kaynak topluluğuna katkıları için

---

**⚠️ Önemli:** Bu proje güvenlik-öncelikli yaklaşımla geliştirilmiştir. Lütfen güvenlik rehberini okuyun ve API anahtarlarınızı koruyun!
