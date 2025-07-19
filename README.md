# FiHikingNetwork 🥾

FiHikingNetwork, hiking yapan grupların birbirini kaybetmemesi ve güvenli bir şekilde iletişim kurması için tasarlanmış iOS uygulamasıdır. iBeacon teknolojisi ve Apple Maps entegrasyonu ile grup üyelerinin gerçek zamanlı konum takibini sağlar.

## 🌟 Özellikler

### 📍 Gerçek Zamanlı Konum Takibi
- Apple Maps ile grup üyelerinin canlı konum gösterimi
- iBeacon teknolojisi ile yakınlık tespiti
- Grup lideri için özel görsel işaretleme (kırmızı bayrak)
- Kendi konumunuz için yeşil işaretleme

### 👥 Grup Yönetimi
- QR kod ile kolay grup katılımı
- Grup oluşturma ve yönetimi
- Grup üyelerinin listesi ve durumları
- Liderlik sistemi

### 🔐 Güvenli Kullanıcı Sistemi
- Firebase Authentication ile güvenli giriş
- SwiftData ile yerel profil cache'leme
- Otomatik profil yükleme (tek seferlik kayıt)

### 📱 Kullanıcı Dostu Arayüz
- SwiftUI ile modern tasarım
- Dark/Light mode desteği
- Accessibility desteği
- VoiceOver uyumluluğu

## 📋 Gereksinimler

- iOS 18.5+
- Xcode 16.0+
- Swift 6.2
- iPhone (iBeacon için fiziksel cihaz önerilir)

## 🛠 Teknolojiler

- **SwiftUI** - Modern UI framework
- **SwiftData** - Local data persistence
- **CoreLocation** - Location services & iBeacon
- **MapKit** - Maps and location visualization
- **Firebase** - Authentication & Firestore
- **MVVM Architecture** - Clean code organization

## 📂 Proje Yapısı

```
FiHikingNetwork/
├── Models/              # Data models (User, Group, BeaconInfo)
├── ViewModels/          # Business logic (MVVM pattern)
├── Views/               # SwiftUI views
├── Helpers/             # Utility classes
├── SwiftData/           # Local data management
└── Assets.xcassets/     # App resources
```

## 🚀 Kurulum

1. **Repository'yi klonlayın:**
   ```bash
   git clone https://github.com/developersailor/FiHikingNetwork.git
   cd FiHikingNetwork
   ```

2. **Xcode'da açın:**
   ```bash
   open FiHikingNetwork.xcodeproj
   ```

3. **Firebase yapılandırması:**
   - Firebase Console'dan `GoogleService-Info.plist` dosyanızı indirin
   - Projeye ekleyin

4. **Çalıştırın:**
   - iPhone simülatör veya fiziksel cihaz seçin
   - ⌘R ile çalıştırın

## 🎯 Kullanım

### İlk Kurulum
1. Uygulamayı açın
2. Profil bilgilerinizi girin (bir kez)
3. Konum izni verin

### Grup Oluşturma
1. Ana ekranda "Grup Oluştur" butonuna tıklayın
2. Grup adını girin
3. QR kodu diğer üyelerle paylaşın

### Gruba Katılma
1. "QR Tarat" butonuna tıklayın
2. Grup liderinin QR kodunu tarayın
3. Otomatik olarak gruba dahil olun

### Harita Görüntüleme
- 🚩 **Kırmızı bayrak**: Grup lideri
- 🟢 **Yeşil daire**: Sizin konumunuz
- 🔵 **Mavi daire**: Diğer grup üyeleri

## 🔧 Geliştirme

### Kod Standartları
- SwiftLint kuralları
- MVVM mimarisi
- 120 karakter satır limiti
- Unit test coverage %80+

### Test Etme
```bash
# Unit testler
⌘U

# UI testler
Test navigator'dan FiHikingNetworkUITests çalıştırın
```

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit edin (`git commit -m 'Add amazing feature'`)
4. Push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📞 İletişim

Mehmet Fıskındal - [@developersailor](https://github.com/developersailor)

Proje Linki: [https://github.com/developersailor/FiHikingNetwork](FiHikingNetwork)

---

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!
