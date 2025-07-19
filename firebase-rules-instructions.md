# Firebase Güvenlik Kurallarını Güncelleme

## Firestore Rules
Firebase Console'da şu kuralları uygulayın:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Kimlik doğrulaması yapılmış kullanıcılar için grup dokümanlarına okuma/yazma erişimi
    match /groups/{groupId} {
      allow read, write: if request.auth != null;
    }
    
    // Kimlik doğrulaması yapılmış kullanıcılar için grup üyelerinin konumlarına okuma erişimi
    match /groups/{groupId}/memberLocations/{memberId} {
      allow read: if request.auth != null;
      // Sadece kendi konumunu güncelleyebilir
      allow write: if request.auth != null && request.auth.uid == memberId;
    }
  }
}
```

## Adımlar
1. Firebase Console'a gidin: https://console.firebase.google.com
2. FiHikingNetwork projenizi seçin
3. Sol menüden "Firestore Database"'e tıklayın
4. "Rules" sekmesine geçin
5. Yukarıdaki kuralları kopyalayıp yapıştırın
6. "Publish" butonuna tıklayın

## Test Etmek İçin
1. Xcode'da uygulamayı çalıştırın (Cmd + R)
2. Profil oluşturun
3. QR kod ile grup oluşturun veya katılın
4. Konsol loglarını takip edin

Artık anonim authentication ile uygulama düzgün çalışmalı!
