# Contributing to FiHikingNetwork 🤝

FiHikingNetwork projesine katkıda bulunmak istediğiniz için teşekkürler! Bu döküman, projeye nasıl katkıda bulunabileceğiniz konusunda size rehberlik edecektir.

## 📋 İçindekiler

- [Code of Conduct](#-code-of-conduct)
- [Nasıl Katkıda Bulunurum?](#-nasıl-katkıda-bulunurum)
- [Geliştirme Ortamı](#-geliştirme-ortamı)
- [Kod Standartları](#-kod-standartları)
- [Commit Mesajları](#-commit-mesajları)
- [Pull Request Süreci](#-pull-request-süreci)
- [Issue Raporlama](#-issue-raporlama)
- [Özellik İstekleri](#-özellik-istekleri)

## 🤲 Code of Conduct

Bu proje [Contributor Covenant](https://www.contributor-covenant.org/) code of conduct'ına uyar. Katılım göstererek, bu kodu desteklemeyi kabul etmiş olursunuz.

## 🚀 Nasıl Katkıda Bulunurum?

### 1. Fork ve Clone
```bash
# Fork edin (GitHub web arayüzünde)
git clone https://github.com/your-username/FiHikingNetwork.git
cd FiHikingNetwork
```

### 2. Branch Oluşturun
```bash
# Feature branch oluşturun
git checkout -b feature/amazing-feature
# veya
git checkout -b bugfix/fix-location-issue
```

### 3. Değişikliklerinizi Yapın
- Kod standartlarına uygun kod yazın
- Testlerinizi yazın
- Dokümantasyonu güncelleyin

### 4. Test Edin
```bash
# Unit testleri çalıştırın
⌘U (Xcode'da)

# Build kontrolü
⌘B (Xcode'da)
```

### 5. Commit ve Push
```bash
git add .
git commit -m "feat: add amazing new feature"
git push origin feature/amazing-feature
```

### 6. Pull Request Oluşturun
GitHub'da pull request açın ve template'i doldurun.

## 🛠 Geliştirme Ortamı

### Gereksinimler
- macOS 13.0+
- Xcode 16.0+
- iOS 18.5+ Simulator/Device
- Git

### Kurulum
1. Projeyi klonlayın
2. Xcode'da `FiHikingNetwork.xcodeproj` açın
3. Firebase yapılandırması için `GoogleService-Info.plist` ekleyin
4. Fiziksel cihaz bağlayın (iBeacon test için)

## 📏 Kod Standartları

### Swift Kodlama Standartları
```swift
// ✅ İyi
func createUserProfile(name: String, age: Int) -> User {
    let user = User(name: name, age: age)
    return user
}

// ❌ Kötü
func createUserProfile(n: String,a: Int)->User{
let user=User(name:n,age:a)
return user
}
```

### Kurallar
- **SwiftLint** kurallarına uyun
- **camelCase** naming kullanın
- **120 karakter** satır limiti
- **MVVM** mimarisine uyun
- **Unit testler** yazın (%80+ coverage)
- **Accessibility** desteği ekleyin
- **Türkçe** ve **İngilizce** lokalizasyon

### Dosya Organizasyonu
```
FiHikingNetwork/
├── Models/              # Data models
├── ViewModels/          # Business logic
├── Views/               # SwiftUI views
├── Helpers/             # Utility classes
├── SwiftData/           # Data persistence
└── Assets.xcassets/     # Resources
```

## 💬 Commit Mesajları

### Commit Message Format
```
type(scope): subject

body (optional)

footer (optional)
```

### Types
- **feat**: Yeni özellik
- **fix**: Bug düzeltmesi
- **docs**: Dokümantasyon
- **style**: Kod formatı (logic değişikliği yok)
- **refactor**: Code refactoring
- **test**: Test ekleme/düzeltme
- **chore**: Build/auxiliary tooling değişiklikleri

### Örnekler
```bash
feat(auth): add Firebase authentication
fix(location): resolve GPS accuracy issue
docs(readme): update installation instructions
style(ui): improve button styling
refactor(viewmodel): extract common logic
test(location): add unit tests for LocationHelper
chore(deps): update Firebase to v12.0.0
```

## 🔄 Pull Request Süreci

### PR Checklist
- [ ] Branch güncel (main ile sync)
- [ ] Kod SwiftLint kurallarına uygun
- [ ] Unit testler yazılmış ve geçiyor
- [ ] UI testler geçiyor (gerekirse)
- [ ] Dokümantasyon güncellenmiş
- [ ] Breaking changes belirtilmiş
- [ ] Fiziksel cihazda test edilmiş (iBeacon için)

### Review Süreci
1. **Automated checks** geçmeli
2. **Code review** minimum 1 approver
3. **Conflicts** çözülmeli
4. **CI/CD** başarılı olmalı

### PR Title Format
```
feat(scope): description
fix(scope): description
docs: description
```

## 🐛 Issue Raporlama

### Bug Report
- **Açık başlık** kullanın
- **Tekrar etme adımları** verin
- **Beklenen vs gerçek** davranış açıklayın
- **Cihaz bilgileri** ekleyin
- **Ekran görüntüleri** ekleyin

### Labels
- `bug` - Bug reports
- `enhancement` - Feature requests
- `documentation` - Documentation improvements
- `good first issue` - Yeni contributors için
- `help wanted` - Yardım aranıyor

## ✨ Özellik İstekleri

### Feature Request Template
1. **Problem tanımı**: Hangi sorunu çözüyor?
2. **Önerilen çözüm**: Nasıl çalışmalı?
3. **Alternatifler**: Başka seçenekler?
4. **Ek bilgiler**: Mockup, referanslar

### Öncelik
1. **Critical**: Güvenlik, data kaybı
2. **High**: Temel fonksiyonalite
3. **Medium**: UX iyileştirmeleri
4. **Low**: Nice-to-have özellikler

## 🏷 Issue ve PR Labels

### Type Labels
- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements or additions to documentation
- `question` - Further information is requested

### Priority Labels
- `priority: critical` - Critical issues
- `priority: high` - High priority
- `priority: medium` - Medium priority
- `priority: low` - Low priority

### Status Labels
- `status: needs review` - Needs review
- `status: in progress` - Currently being worked on
- `status: blocked` - Blocked by other work

### Area Labels
- `area: ui` - User interface
- `area: backend` - Backend/Firebase
- `area: location` - Location services
- `area: bluetooth` - iBeacon/Bluetooth

## 📱 Test Guidelines

### Unit Tests
```swift
// Test example
func testLocationPermissionRequest() {
    // Given
    let locationHelper = LocationHelper()
    
    // When
    locationHelper.requestPermission()
    
    // Then
    XCTAssertTrue(locationHelper.hasPermission)
}
```

### UI Tests
- Ana user flow'ları test edin
- Accessibility testleri ekleyin
- Error durumlarını test edin

## 🌍 Lokalizasyon

### Yeni String Ekleme
```swift
// Localizable.strings (tr)
"welcome.title" = "Hoş Geldiniz";
"welcome.subtitle" = "Hiking maceralarınız başlıyor";

// Localizable.strings (en)
"welcome.title" = "Welcome";
"welcome.subtitle" = "Your hiking adventures begin";

// SwiftUI'da kullanım
Text("welcome.title")
```

## 🎖 Recognition

Katkıda bulunan herkesi [Contributors](CONTRIBUTORS.md) dosyasında tanıyoruz!

## 📞 İletişim

Sorularınız için:
- GitHub Issues kullanın
- [@developersailor](https://github.com/developersailor) ile iletişime geçin

---

Katkıda bulunduğunuz için teşekkürler! 🙏
