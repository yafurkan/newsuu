# Güvenlik Politikası

## Desteklenen Sürümler

Aşağıdaki sürümler için güvenlik açıklarına yönelik yama sürümleri yayınlıyoruz:

| Sürüm | Destek Durumu     |
| ----- | ----------------- |
| 2.1.x | :white_check_mark: |
| 2.0.x | :x:                |
| 1.0.x | :x:                |

## Güvenlik Açığı Bildirme

Bu proje içinde bir güvenlik açığı keşfederseniz, lütfen [Suutakip@gmail.com](mailto:Suutakip@gmail.com) adresine bir e-posta gönderin. Tüm güvenlik açıkları derhal ele alınacaktır.

Lütfen güvenlik açığını, ekip tarafından ele alınana kadar kamuya açık olarak ifşa etmeyin.

## Güvenlik Önlemleri

Güvenliği ciddiye alıyoruz ve aşağıdaki önlemleri uyguladık:

1. **Ortam Değişkenleri Koruması**: Hassas bilgiler `.env` dosyalarında saklanır ve `.gitignore` ile sürüm kontrolünden hariç tutulur
2. **Firebase Güvenlik Kuralları**: Firestore kuralları, yetkisiz erişimi önlemek için yapılandırılmıştır
3. **Giriş Doğrulama**: Tüm kullanıcı girişleri, enjeksiyon saldırılarını önlemek için doğrulanır
4. **Güvenli API Çağrıları**: Tüm harici API iletişimlerinde HTTPS kullanılır
5. **Kod İncelemeleri**: Tüm değişiklikler, ana dala birleştirilmeden önce incelenir
6. **Bağımlılık Güncellemeleri**: Bağımlılıkları güvenli tutmak için düzenli güncellemeler

## Katkıda Bulunanlar için Güvenlik En İyi Uygulamaları

1. Hassas bilgileri (API anahtarları, şifreler vb.) asla depoya işlemeyin
2. Yapılandırma için ortam değişkenlerini kullanın
3. Özellikleri uygularken en az ayrıcalık ilkesini izleyin
4. Tüm kullanıcı girişlerini doğrulayın
5. Bağımlılıkları güncel tutun
6. Herhangi bir güvenlik endişesini derhal bildirin

## İletişim

Herhangi bir güvenlikle ilgili soru veya endişe için lütfen iletişime geçin:

- Proje Güvenlik Ekibi - [Suutakip@gmail.com](mailto:Suutakip@gmail.com)

Sorumlulukla bulgularınızı ifşa etme çabalarınızı takdir ediyoruz ve katkılarınızı kabul etmek için her türlü çabayı göstereceğiz.
