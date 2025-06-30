/// Uygulama genelinde kullanılacak metin sabitleri
class AppStrings {
  // Uygulama genel
  static const String appName = 'Suu';
  static const String appTagline = 'Günlük su ihtiyacınızı takip edin';

  // Onboarding
  static const String onboardingTitle1 = 'Hoş Geldiniz!';
  static const String onboardingSubtitle1 =
      'Su Takip uygulamasıyla günlük su ihtiyacınızı kolayca takip edin';

  static const String onboardingTitle2 = 'Günlük Hedef';
  static const String onboardingSubtitle2 =
      'Kişiselleştirilmiş günlük su hedefinizi belirleyin ve ulaşın';

  static const String onboardingTitle3 = 'İstatistikler';
  static const String onboardingSubtitle3 =
      'Günlük, haftalık ve aylık su tüketim grafiklerinizi görüntüleyin';

  // Butonlar
  static const String next = 'İleri';
  static const String back = 'Geri';
  static const String skip = 'Geç';
  static const String getStarted = 'Başlayalım';
  static const String save = 'Kaydet';
  static const String cancel = 'İptal';
  static const String ok = 'Tamam';
  static const String retry = 'Tekrar Dene';
  static const String update = 'Güncelle';
  static const String delete = 'Sil';
  static const String edit = 'Düzenle';

  // Profil oluşturma
  static const String createProfile = 'Profil Oluştur';
  static const String personalInfo = 'Kişisel Bilgiler';
  static const String firstName = 'Ad';
  static const String lastName = 'Soyad';
  static const String age = 'Yaş';
  static const String weight = 'Kilo (kg)';
  static const String height = 'Boy (cm)';
  static const String gender = 'Cinsiyet';
  static const String male = 'Erkek';
  static const String female = 'Kadın';
  static const String activityLevel = 'Aktivite Seviyesi';
  static const String low = 'Düşük';
  static const String medium = 'Orta';
  static const String high = 'Yüksek';

  // Ana ekran
  static const String todayIntake = 'Bugünkü Su Alımı';
  static const String dailyGoal = 'Günlük Hedef';
  static const String addWater = 'Su Ekle';
  static const String quickAdd = 'Hızlı Ekle';
  static const String customAmount = 'Özel Miktar';
  static const String congratulations = 'Tebrikler!';
  static const String goalCompleted = 'Günlük hedefinizi tamamladınız!';
  static const String keepGoing = 'Harika gidiyorsunuz!';

  // Su miktarları
  static const String ml = 'ml';
  static const String liter = 'L';
  static const String glass = 'bardak';
  static const String cup = 'fincan';

  // İstatistikler
  static const String statistics = 'İstatistikler';
  static const String dailyStats = 'Günlük';
  static const String weeklyStats = 'Haftalık';
  static const String monthlyStats = 'Aylık';
  static const String averageIntake = 'Ortalama Alım';
  static const String totalIntake = 'Toplam Alım';
  static const String bestDay = 'En İyi Gün';
  static const String streak = 'Seri';
  static const String days = 'gün';

  // Profil
  static const String profile = 'Profil';
  static const String editProfile = 'Profili Düzenle';
  static const String settings = 'Ayarlar';
  static const String notifications = 'Bildirimler';
  static const String reminderSettings = 'Hatırlatma Ayarları';
  static const String theme = 'Tema';
  static const String about = 'Hakkında';
  static const String privacy = 'Gizlilik';
  static const String terms = 'Kullanım Şartları';

  // Bildirimler
  static const String reminder = 'Su İçme Zamanı!';
  static const String reminderBody =
      'Günlük hedefinize ulaşmak için biraz daha su içmeyi unutmayın.';

  // Hatalar
  static const String error = 'Hata';
  static const String errorGeneric = 'Bir hata oluştu. Lütfen tekrar deneyin.';
  static const String errorNetwork = 'İnternet bağlantınızı kontrol edin.';
  static const String errorValidation =
      'Lütfen tüm alanları doğru şekilde doldurun.';

  // Form validasyonları
  static const String fieldRequired = 'Bu alan zorunludur';
  static const String invalidAge = 'Geçerli bir yaş giriniz (18-100)';
  static const String invalidWeight = 'Geçerli bir kilo giriniz (30-300 kg)';
  static const String invalidHeight = 'Geçerli bir boy giriniz (100-250 cm)';
  static const String invalidAmount = 'Geçerli bir miktar giriniz';

  // Başarı mesajları
  static const String profileSaved = 'Profil başarıyla kaydedildi';
  static const String waterAdded = 'Su miktarı eklendi';
  static const String goalReached = 'Günlük hedefe ulaştınız!';

  // Zamanlar
  static const String morning = 'Sabah';
  static const String afternoon = 'Öğleden Sonra';
  static const String evening = 'Akşam';
  static const String night = 'Gece';

  // Haftanın günleri (kısaltma)
  static const List<String> weekDaysShort = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  // Aylar
  static const List<String> months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];
}
