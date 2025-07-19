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
    
    // MARK: - Private Properties
    
    private let authService: AuthService
    private let disposeBag = DisposeBag()

    // MARK: - Initializer
    
    init(authService: AuthService = AuthService()) {
        self.authService = authService
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
            self.appState = .signedIn
        } else {
            self.appState = .signedOut
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