import Foundation
import FirebaseAuth
import RxSwift

/// Kullanıcı kimlik doğrulama durumlarını ve işlemlerini yöneten servis.
class AuthService {
    
    // MARK: - Properties
    
    /// Mevcut kullanıcının kimlik doğrulama durumunu yayınlayan bir BehaviorSubject.
    /// Başlangıçta mevcut oturumdaki kullanıcıyı veya nil değerini alır.
    let authState = BehaviorSubject<FirebaseAuth.User?>(value: Auth.auth().currentUser)
    
    private var listenerHandle: AuthStateDidChangeListenerHandle?
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init() {
        // Firebase'in kimlik doğrulama durumu değişikliklerini dinler ve `authState`'i günceller.
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            self?.authState.onNext(user)
        }
    }
    
    deinit {
        if let listenerHandle = listenerHandle {
            Auth.auth().removeStateDidChangeListener(listenerHandle)
        }
    }
    
    // MARK: - Public Methods
    
    /// Mevcut kullanıcının UID'sini bir Observable olarak döndürür.
    /// Kullanıcı giriş yapmamışsa, nil yayınlar.
    func observeCurrentUserUID() -> Observable<String?> {
        return authState.map { $0?.uid }
    }
    
    /// Anonim olarak bir kullanıcı oluşturur ve oturum açar.
    /// Bu, uygulamanın ilk açılışında veya kullanıcı hesabı olmadan devam etmek istediğinde kullanışlıdır.
    /// - Returns: Başarılı olursa kullanıcı UID'sini, olmazsa hata döndüren bir Single.
    func signInAnonymously() -> Single<String> {
        return Single.create { single in
            Auth.auth().signInAnonymously { (authResult, error) in
                if let error = error {
                    single(.failure(error))
                } else if let user = authResult?.user {
                    single(.success(user.uid))
                } else {
                    single(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Anonim giriş başarısız oldu."])))
                }
            }
            return Disposables.create()
        }
    }
    
    /// Mevcut kullanıcının oturumunu kapatır.
    func signOut() -> Completable {
        return Completable.create { completable in
            do {
                try Auth.auth().signOut()
                completable(.completed)
            } catch let error {
                completable(.error(error))
            }
            return Disposables.create()
        }
    }
}
