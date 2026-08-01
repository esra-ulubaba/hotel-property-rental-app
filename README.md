# 🏨 Otel ve Emlak Kiralama Uygulaması

Flutter ve Firebase kullanılarak geliştirilmiş, **Stripe** ile online ödeme entegrasyonuna sahip otel ve emlak kiralama uygulaması. Airbnb benzeri bir kullanıcı deneyimi sunar; kullanıcılar konaklama ilanlarını arayabilir, filtreleyebilir, detaylarını inceleyebilir, rezervasyon yapabilir ve online ödeme gerçekleştirebilir.

## ✨ Özellikler

- 🔍 **İlan Arama & Filtreleme** — Konum, tarih, fiyat aralığı ve oda özelliklerine göre arama
- 🛏️ **Oda/Yatak Detayları** — Tek/çift kişilik, çift ve kral/kraliçe boy yatak seçenekleri ile misafir kapasitesi hesaplama
- 🏠 **İlan Yönetimi** — Ev sahiplerinin kendi ilanlarını oluşturup yönetebilmesi
- ⭐ **Değerlendirme Sistemi** — Kullanıcıların konaklamalar hakkında yorum ve puan bırakabilmesi
- 💳 **Online Ödeme** — Stripe entegrasyonu ile güvenli rezervasyon ödemesi
- 🔐 **Kullanıcı Yönetimi** — Firebase Authentication ile kayıt/giriş işlemleri
- ☁️ **Bulut Veritabanı** — Firebase Firestore ile gerçek zamanlı veri senkronizasyonu

## 🛠️ Kullanılan Teknolojiler

| Teknoloji | Amaç |
|---|---|
| **Flutter** | Cross-platform mobil uygulama geliştirme |
| **Firebase Authentication** | Kullanıcı kimlik doğrulama |
| **Firebase Firestore** | Bulut tabanlı veritabanı |
| **Firebase Storage** | Görsel/medya depolama |
| **Stripe** | Online ödeme altyapısı |

## 📂 Proje Yapısı

```
lib/
 ├── models/           # Veri modelleri (kullanıcı, ilan vb.)
 ├── screens/          # Uygulama ekranları
 ├── widgets/          # Yeniden kullanılabilir UI bileşenleri
 └── services/         # Firebase & Stripe servis katmanı
android/               # Android platform dosyaları
ios/                   # iOS platform dosyaları
assets/                # Görseller ve statik dosyalar
test/                  # Test dosyaları
```

## 🚀 Kurulum

Projeyi yerel makinenizde çalıştırmak için:

1. **Repoyu klonlayın**
   ```bash
   git clone https://github.com/esra-ulubaba/hotel-property-rental-app.git
   cd hotel-property-rental-app
   ```

2. **Bağımlılıkları yükleyin**
   ```bash
   flutter pub get
   ```

3. **Firebase yapılandırması**
   - Kendi Firebase projenizi oluşturun ([Firebase Console](https://console.firebase.google.com/))
   - `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını ilgili klasörlere ekleyin

4. **Ortam değişkenlerini ayarlayın**
   - Proje kök dizininde bir `.env` dosyası oluşturun
   - Stripe API anahtarınızı ve gerekli diğer gizli bilgileri buraya ekleyin (bu dosya `.gitignore` içinde olduğu için repoya dahil edilmez)

5. **Uygulamayı çalıştırın**
   ```bash
   flutter run
   ```

## 📋 Gereksinimler

- Flutter SDK (kararlı sürüm)
- Dart SDK
- Android Studio veya VS Code
- Aktif bir Firebase projesi
- Stripe hesabı ve API anahtarları

## 📱 Ekran Görüntüleri

