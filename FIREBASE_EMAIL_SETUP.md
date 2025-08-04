# 📧 Firebase E-posta Sistemi Kurulum Rehberi

## 🎯 Amaç
Su Takip uygulaması için:
- E-posta doğrulama maillerinin gönderilmesi
- Hoş geldin e-postalarının otomatik gönderilmesi
- Günlük özet ve hedef tamamlama e-postalarının gönderilmesi

## 🔧 Firebase Console Ayarları

### 1. Authentication E-posta Şablonları

#### A) Firebase Console'a Git
1. [Firebase Console](https://console.firebase.google.com) → Projenizi seçin
2. **Authentication** → **Templates** sekmesi

#### B) E-posta Doğrulama Şablonu
1. **Email address verification** seçin
2. **Customize** butonuna tıklayın
3. Şablonu düzenleyin:

```
Subject: Su Takip - E-posta Adresinizi Doğrulayın 💧

Body:
Merhaba %DISPLAY_NAME%,

Su Takip uygulamasına hoş geldiniz! 🎉

E-posta adresinizi doğrulamak için aşağıdaki bağlantıya tıklayın:
%LINK%

Bu bağlantı 1 saat içinde geçerliliğini yitirecektir.

E-posta adresinizi doğruladıktan sonra uygulamanın tüm özelliklerini kullanabileceksiniz:
• Su tüketimi takibi 💧
• Akıllı hatırlatmalar ⏰
• İstatistikler ve raporlar 📊
• Hedef belirleme 🎯

Sorularınız için: destek@sutakip.com

Su Takip Ekibi
```

#### C) Şifre Sıfırlama Şablonu
1. **Password reset** seçin
2. **Customize** butonuna tıklayın
3. Şablonu düzenleyin:

```
Subject: Su Takip - Şifre Sıfırlama 🔐

Body:
Merhaba %DISPLAY_NAME%,

Şifrenizi sıfırlamak için aşağıdaki bağlantıya tıklayın:
%LINK%

Bu bağlantı 1 saat içinde geçerliliğini yitirecektir.

Eğer şifre sıfırlama talebinde bulunmadıysanız, bu e-postayı görmezden gelebilirsiniz.

Su Takip Ekibi
```

### 2. Authorized Domains
1. **Authentication** → **Settings** → **Authorized domains**
2. Aşağıdaki domain'leri ekleyin:
   - `localhost` (geliştirme için)
   - `sutakip.com` (production domain)
   - `sutakip.firebaseapp.com` (Firebase hosting)

### 3. Project Settings
1. **Project Settings** → **General**
2. **Public-facing name**: "Su Takip"
3. **Support email**: Geçerli bir e-posta adresi girin

## 🚀 Firebase Extensions Kurulumu (Hoş Geldin E-postası İçin)

### 1. Trigger Email Extension
1. Firebase Console → **Extensions**
2. **Browse Hub** → "Trigger Email" ara
3. **Install** butonuna tıklayın

### 2. Extension Ayarları
```
Collection path: mail
Email documents field: to
Default from: noreply@sutakip-app.firebaseapp.com
Default reply to: destek@sutakip.com
```

### 3. E-posta Şablonları Oluştur
Extensions kurulduktan sonra şablonları oluşturun:

#### A) Hoş Geldin E-postası Şablonu
```html
<!-- welcome-email.html -->
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Su Takip'e Hoş Geldiniz!</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #4A90E2, #7B68EE); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
        .button { background: #4A90E2; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 20px 0; }
        .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎉 Su Takip'e Hoş Geldiniz!</h1>
            <p>Sağlıklı yaşam yolculuğunuz başlıyor</p>
        </div>
        <div class="content">
            <p>Merhaba <strong>{{displayName}}</strong>,</p>
            
            <p>Su Takip ailesine katıldığınız için çok mutluyuz! 💧</p>
            
            <p>Uygulamızla neler yapabilirsiniz:</p>
            <ul>
                <li>🥤 Günlük su tüketiminizi takip edin</li>
                <li>⏰ Akıllı hatırlatmalar alın</li>
                <li>📊 Detaylı istatistikler görün</li>
                <li>🎯 Kişisel hedefler belirleyin</li>
                <li>🏆 Başarılarınızı kutlayın</li>
            </ul>
            
            <p>Hemen başlamak için uygulamayı açın ve ilk su bardağınızı kaydedin!</p>
            
            <a href="sutakip://open" class="button">Uygulamayı Aç</a>
            
            <p>Sorularınız için bize <a href="mailto:{{supportEmail}}">{{supportEmail}}</a> adresinden ulaşabilirsiniz.</p>
            
            <p>Sağlıklı günler dileriz! 🌟</p>
        </div>
        <div class="footer">
            <p>Su Takip Ekibi<br>
            Bu e-postayı {{email}} adresine gönderiyoruz.</p>
        </div>
    </div>
</body>
</html>
```

## 🔍 Test Etme

### 1. E-posta Doğrulama Testi
```dart
// Test kodu
final user = FirebaseAuth.instance.currentUser;
if (user != null && !user.emailVerified) {
  await user.sendEmailVerification();
  print('E-posta doğrulama gönderildi');
}
```

### 2. Hoş Geldin E-postası Testi
```dart
// Test kodu
final emailService = EmailService();
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  await emailService.sendWelcomeEmail(user);
  print('Hoş geldin e-postası gönderildi');
}
```

## 🚨 Sorun Giderme

### E-posta Gelmiyor?
1. **Spam klasörünü kontrol edin**
2. **Firebase Console → Authentication → Templates** ayarlarını kontrol edin
3. **Authorized domains** listesini kontrol edin
4. **Project Settings → Support email** ayarını kontrol edin

### Extension Çalışmıyor?
1. **Extensions** sekmesinde extension'ın aktif olduğunu kontrol edin
2. **Firestore Rules** ayarlarını kontrol edin:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /mail/{document} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Geliştirme Ortamında Test
1. **Firebase Emulator Suite** kullanın
2. **Local SMTP server** kurun (MailHog gibi)
3. **Console loglarını** takip edin

## 📝 Notlar

- Firebase'in ücretsiz planında günlük 100 e-posta limiti vardır
- Production'da custom domain kullanmak için Firebase Hosting gereklidir
- E-posta şablonları HTML ve plain text formatında olabilir
- Extension'lar Firebase Functions kullanır, bu nedenle Blaze planı gerekebilir

## 🔗 Faydalı Linkler

- [Firebase Auth Email Templates](https://firebase.google.com/docs/auth/custom-email-handler)
- [Trigger Email Extension](https://extensions.dev/extensions/firebase/firestore-send-email)
- [Firebase Extensions Documentation](https://firebase.google.com/docs/extensions)