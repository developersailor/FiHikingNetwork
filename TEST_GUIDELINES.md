# Test Rehberi - FiHikingNetwork

## Konum Güncellenemedi Hatası - Düzeltildi ✅

### Yapılan Düzeltmeler:
✅ **Konum Koleksiyonu**: `locations` → `memberLocations` olarak değiştirildi
✅ **Detailed Logging**: Tüm konum işlemlerinde kapsamlı log mesajları eklendi
✅ **Firebase Security Rules**: `memberLocations` koleksiyonu için güncellendi
✅ **Location Manager**: Konum izinleri ve hata kontrolü geliştirildi
✅ **Document Structure**: Firestore document path'i düzeltildi

## Test Senaryoları

### 1. Anonim Giriş Testi
1. Uygulamayı başlatın
2. **"Anonim Giriş"** butonuna tıklayın
3. Firebase Console'da anonymous user oluşturulduğunu kontrol edin
4. Profil oluşturma ekranına geçtiğini doğrulayın

### 2. Konum İzni Testi
1. Anonim girişten sonra
2. iOS Settings > Privacy & Security > Location Services'e gidin
3. FiHikingNetwork uygulaması için "While Using App" seçin
4. Uygulamaya döndüğünüzde konum güncellemelerinin başladığını kontrol edin

### 3. Konum Güncelleme Testi  
1. Profil oluşturduktan sonra grup oluşturun
2. Konsol loglarında şu mesajları arayın:
   - `🗺️ MapViewModel: Location updated - Lat: X, Lon: Y`
   - `🗺️ GroupViewModel: Updating location for group [groupId]`
   - `✅ LocationService: Location updated successfully`

### 4. Grup İşlemleri Testi
1. Ana ekranda grup oluşturun
2. QR kod ile grup paylaşın
3. Başka bir cihazda QR kod okutarak gruba katılın
4. Firebase Console'da `groups/{groupId}/memberLocations` koleksiyonunu kontrol edin

## Debug Konsol Mesajları

### Başarılı Konum Güncellemeleri:
- `🗺️ MapViewModel: Requesting location permission`
- `✅ MapViewModel: Location permission granted, starting updates`  
- `🗺️ MapViewModel: Location updated - Lat: [lat], Lon: [lon]`
- `🗺️ GroupViewModel: Updating location for group [groupId]`
- `🗺️ LocationService: Updating location for user [userId]`
- `✅ LocationService: Location updated successfully`

### Hata Durumları:
- `❌ MapViewModel: Location permission denied`
- `❌ LocationService: Location update failed - [error]`
- `❌ GroupViewModel: Location update failed - [error]`

## Firebase Console Kontrolleri
1. **Authentication > Users**: Anonim kullanıcılar görünmeli
2. **Firestore > groups**: Grup dokümanları oluşturulmalı  
3. **Firestore > groups/{groupId}/memberLocations**: Konum dokümanları burada olmalı (artık `locations` değil!)

## Firebase Güvenlik Kuralları
`firestore_rules_fixed.txt` dosyasındaki kuralları Firebase Console'da uygulayın:

```javascript
// Grup içi konumlar: grup üyesi olanlar tüm konumları okuyabilir, sadece kendi konumunu yazabilir
match /groups/{groupId}/memberLocations/{userId} {
  // Grup üyesi olanlar tüm konumları okuyabilir (harita görünümü için gerekli)
  allow read: if request.auth != null && 
                 (request.auth.uid == userId || 
                  exists(/databases/$(database)/documents/groups/$(groupId)) && 
                  request.auth.uid in get(/databases/$(database)/documents/groups/$(groupId)).data.members);
  
  // Sadece kendi konum dokümanını yazabilir
  allow write: if request.auth != null && request.auth.uid == userId;
}
```

Artık konum güncelleme hatası çözülmüş olmalı! 🗺️✅
