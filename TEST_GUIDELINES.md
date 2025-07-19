# Test Rehberi - FiHikingNetwork

## Yeni Özellikler
✅ **Anonim Giriş Butonu**: AuthView'de "Anonim Giriş" butonu eklendi
✅ **Onboarding Akışı**: Profil oluşturulduktan sonra otomatik ana ekrana geçiş
✅ **Profil Atlama**: "Atla" butonu ile boş profil oluşturma

## Test Senaryoları

### 1. Anonim Giriş Testi
1. Uygulamayı başlatın
2. **"Anonim Giriş"** butonuna tıklayın
3. Firebase Console'da anonymous user oluşturulduğunu kontrol edin
4. Profil oluşturma ekranına geçtiğini doğrulayın

### 2. Profil Oluşturma Testi
1. Anonim girişten sonra profil ekranında:
   - İsim, kullanıcı adı ve telefon bilgilerini girin
   - **"Profil Oluştur"** butonuna tıklayın
2. Ana uygulamaya geçtiğini doğrulayın

### 3. Profil Atlama Testi
1. Profil ekranında **"Atla"** butonuna tıklayın
2. Otomatik profil oluşturulup ana uygulamaya geçtiğini doğrulayın

### 4. Grup İşlemleri Testi
1. Ana ekranda grup oluşturun
2. QR kod ile grup paylaşın
3. Başka bir cihazda QR kod okutarak gruba katılın
4. Konsol loglarında işlemleri takip edin

## Konsol Mesajları
- `✅ Profile created, notifying AppViewModel`
- `✅ Profile skipped, notifying AppViewModel` 
- `Anonim giriş başarılı: [userID]`
- `Group joined successfully`
- `QR Scanner: [detaylı mesajlar]`

## Firebase Console Kontrolleri
1. Authentication > Users: Anonim kullanıcılar görünmeli
2. Firestore > groups: Grup dokümanları oluşturulmalı
3. Firestore > groups/{groupId}/memberLocations: Konum dokümanları

## Hata Durumları
- Network hatası: Hata mesajı gösterilmeli
- Firebase kuralları: Erişim reddedilirse hata logu
- QR kod okuma hatası: Kullanıcıya bilgi verilmeli

Tüm testleri tamamladıktan sonra Firebase güvenlik kurallarını `firestore_rules_fixed.txt` dosyasından uygulayın!
