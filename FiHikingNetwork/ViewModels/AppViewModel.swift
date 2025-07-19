import Foundation
import Combine
import RxSwift
import FirebaseAuth

/// Uygulamanın genel durumunu ve kimlik doğrulama akışını yöneten ana ViewModel.
@MainActor
class AppViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Mevcut kullanıcının kimlik durumunu (UID) tutar.
    /// `nil` ise kullanıcı giriş yapmamış demektir.
    @Published private(set) var currentUserID: String?
    
    /// Uygulamanın genel durumunu belirtir.
    @Published private(set) var appState: AppState = .loading
    
    /// Kullanıcı profili oluşturuldu mu kontrolü
    @Published var hasUserProfile: Bool = false
    
    // MARK: - Private Properties
    
    private let authService: AuthService
    private let disposeBag = DisposeBag()

    // MARK: - Initializer
    
    init(authService: AuthService = AuthService()) {
        self.authService = authService
        
        // Önce cache'den profil kontrolü yap
        if LocalDataManager.shared.loadUser() != nil {
            self.hasUserProfile = true
            print("✅ AppViewModel Init: Cache'de profil bulundu")
        } else {
            self.hasUserProfile = false
            print("❌ AppViewModel Init: Cache'de profil bulunamadı")
        }
        
        setupBindings()
        signInUser()
    }
    
    // MARK: - Private Methods
    
    /// AuthService'den gelen kimlik doğrulama durumu değişikliklerini dinler.
    private func setupBindings() {
        authService.observeCurrentUserUID()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] userID in
                self?.currentUserID = userID
                self?.updateAppState(userID: userID)
            })
            .disposed(by: disposeBag)
    }
    
    /// Kullanıcı ID'sine göre uygulama durumunu günceller.
    private func updateAppState(userID: String?) {
        if let userID = userID, !userID.isEmpty {
            // Kullanıcı giriş yapmış, profil kontrolü yap
            checkUserProfile()
        } else {
            self.appState = .signedOut
            self.hasUserProfile = false
        }
    }
    
    /// Cache'den kullanıcı profilini kontrol et
    private func checkUserProfile() {
        let localDataManager = LocalDataManager.shared
        if let cachedUser = localDataManager.loadUser() {
            print("✅ Cache'den kullanıcı profili bulundu: \(cachedUser.name)")
            self.hasUserProfile = true
            self.appState = .signedIn
        } else {
            print("❌ Cache'de kullanıcı profili bulunamadı")
            self.hasUserProfile = false
            self.appState = .signedOut // Onboarding göster
        }
    }
    
    /// Profil oluşturulduğunu belirt ve ana ekrana geç
    func setUserProfileCreated() {
        hasUserProfile = true
        if currentUserID != nil {
            self.appState = .signedIn
        }
    }
    
    /// Kullanıcıyı anonim olarak sisteme dahil eder.
    /// Eğer zaten bir oturum varsa, bu adımı atlar.
    private func signInUser() {
        // BehaviorSubject'in son değerini kontrol et. `try?` ile optional döndürür.
        if let user = try? authService.authState.value() {
            print("Mevcut oturum bulundu: \(user.uid)")
            self.updateAppState(userID: user.uid)
            return
        }
        
        print("Mevcut oturum bulunamadı, anonim giriş yapılıyor...")
        appState = .loading
        
        authService.signInAnonymously()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { userID in
                print("Anonim giriş başarılı. UID: \(userID)")
                // Durum güncellemesi zaten `setupBindings` tarafından yapılacak.
            }, onFailure: { [weak self] error in
                print("Anonim giriş başarısız: \(error.localizedDescription)")
                self?.appState = .error(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - AppState Enum
extension AppViewModel {
    enum AppState {
        case loading
        case signedIn
        case signedOut
        case error(String)
    }
}