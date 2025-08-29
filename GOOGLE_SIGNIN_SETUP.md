# Google Sign-in Kurulum Rehberi

## Firebase Console'da Yapılması Gerekenler:

### 1. Authentication Etkinleştirme
- Firebase Console → Authentication → Sign-in method
- Google Sign-in'i etkinleştir
- Android için SHA-1 fingerprint eklenmeli
- Web client ID almak

### 2. SHA-1 Fingerprint Alma
```bash
cd android
./gradlew signingReport
```

### 3. OAuth consent screen (Google Cloud Console)
- Google Cloud Console'da OAuth consent screen kurulumu
- Uygulama adı: "Su Takip"
- User support email
- Developer contact email

## Gerekli Dosya Değişiklikleri:

### android/build.gradle
- Google services plugin

### android/app/build.gradle  
- applicationId kontrolü
- SHA-1 ekleme

### lib/screens/
- login_screen.dart (yeni)
- Splash screen güncelleme
- main.dart route güncelleme

## Test Adımları:
1. Çıkış yap → Giriş ekranına git
2. Google ile giriş yap
3. Eski kullanıcı verilerini sakla
4. Yeni kullanıcı onboarding'e git
