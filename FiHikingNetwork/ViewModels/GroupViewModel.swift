import Foundation
import CoreLocation
import RxSwift
import RxCocoa
import FirebaseFirestore
import Combine // Hata düzeltmesi: Publisher için Combine import edildi

/// Grup yönetimi, konum güncellemeleri ve Firestore etkileşimlerini yöneten ViewModel.
class GroupViewModel: ObservableObject {
    
    // MARK: - Published Properties for SwiftUI
    @Published var group: HikingGroup?
    @Published var memberLocations: [MemberLocation] = []
    @Published var errorMessage: String?
    @Published var isUpdatingLocation = false
    
    // MARK: - Private Properties
    private let groupService: GroupService
    private let locationManager: LocationManager
    private let disposeBag = DisposeBag()
    
    // Mevcut kullanıcı kimliği. View'ın erişebilmesi için 'private' değil.
    let currentUserID: String
    
    // MARK: - Initializer
    init(group: HikingGroup? = nil,
         currentUserID: String,
         groupService: GroupService = GroupService(),
         locationManager: LocationManager = LocationManager()) {
        self.group = group
        self.currentUserID = currentUserID
        self.groupService = groupService
        self.locationManager = locationManager
        
        setupBindings()
    }
    
    // MARK: - Rx Bindings
    private func setupBindings() {
        // 1. Konum Yöneticisinden gelen güncellemeleri dinle ve Firestore'a yaz
        locationManager.locationUpdates
            .debounce(.seconds(15), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] location in
                self?.updateUserLocationInFirestore(location)
            })
            .disposed(by: disposeBag)
            
        // 2. Aktif grup ID'sini dinle
        let groupIDObservable = $group
            .compactMap { $0?.id.uuidString }
            .removeDuplicates()
            .asObservable() // Combine Publisher'ı RxSwift Observable'a çevir

        // 3. Grup ID'si değiştiğinde, yeni grubun konumlarını dinlemeye başla
        groupIDObservable
            .flatMapLatest { [weak self] groupId -> Observable<[MemberLocation]> in
                guard let self = self else { return .empty() }
                return self.groupService.listenForLocationUpdates(groupId: groupId)
                    .catch { [weak self] error in
                        self?.errorMessage = "Üye konumları alınamadı: \(error.localizedDescription)"
                        return .just([])
                    }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] locations in
                self?.memberLocations = locations
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public Methods
    
    func startLocationTracking() {
        locationManager.requestLocationPermission()
    }
    
    func stopLocationTracking() {
        locationManager.stopLocationUpdates()
    }
    
    func createGroup(name: String, memberIDs: [String]) {
        print("Grup oluşturma işlemi başlatılıyor. Ad: \(name), Üyeler: \(memberIDs)")
        
        groupService.createGroup(name: name, memberIDs: memberIDs, leaderId: currentUserID)
            .flatMap { [unowned self] createdGroupId -> Single<[String: Any]> in
                print("Grup başarıyla oluşturuldu, ID: \(createdGroupId). Grup bilgisi çekiliyor...")
                // Oluşturulan grubun bilgilerini çek
                return self.groupService.fetchGroup(groupId: createdGroupId)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] groupData in
                print("Grup bilgisi işleniyor: \(groupData)")
                
                let groupUUID = UUID(uuidString: groupData["id"] as? String ?? "") ?? UUID()
                let groupName = groupData["name"] as? String ?? "Bilinmeyen Grup"
                
                // Members alanını String array olarak al ve UUID array'e çevir
                let membersStringArray = groupData["members"] as? [String] ?? []
                print("Oluşturulan grup üyeleri: \(membersStringArray)")
                
                // String'leri UUID'lere çevir
                let memberUUIDs = membersStringArray.map { memberString -> UUID in
                    if let uuid = UUID(uuidString: memberString) {
                        return uuid
                    } else {
                        print("String ID UUID'ye çevriliyor: \(memberString)")
                        return UUID()
                    }
                }
                
                let newGroup = HikingGroup(
                    id: groupUUID,
                    name: groupName,
                    memberIDs: memberUUIDs
                )
                self?.group = newGroup
                print("Grup başarıyla oluşturuldu ve ayarlandı. Grup: \(groupName), Üye sayısı: \(memberUUIDs.count)")
            }, onFailure: { [weak self] error in
                print("Grup oluşturma hatası: \(error.localizedDescription)")
                self?.errorMessage = "Grup oluşturulamadı: \(error.localizedDescription)"
            })
            .disposed(by: disposeBag)
    }
    
    /// Kullanıcıyı belirtilen gruba dahil eder.
    /// - Parameter groupId: Katılınacak grubun kimliği.
    func joinGroup(groupId: String) {
        print("Gruba katılma işlemi başlatılıyor. GroupID: \(groupId), UserID: \(currentUserID)")
        
        groupService.addMemberToGroup(userId: currentUserID, to: groupId)
            .flatMap { [unowned self] () -> Single<[String: Any]> in
                print("Kullanıcı başarıyla gruba eklendi, grup bilgisi çekiliyor...")
                // Üye ekleme başarılı olduktan sonra, güncel grup bilgisini çekiyoruz.
                return self.groupService.fetchGroup(groupId: groupId)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] groupData in
                print("Grup bilgisi alındı: \(groupData)")
                
                // Firestore'dan gelen veriyi local HikingGroup modeline çevir
                let groupUUID = UUID(uuidString: groupData["id"] as? String ?? "") ?? UUID()
                let groupName = groupData["name"] as? String ?? "Bilinmeyen Grup"
                
                // Members alanını String array olarak al ve UUID array'e çevir
                let membersStringArray = groupData["members"] as? [String] ?? []
                print("Firestore'dan gelen üyeler: \(membersStringArray)")
                
                // String'leri UUID'lere çevir - hatalı UUID'ler için yeni UUID oluştur
                let memberUUIDs = membersStringArray.map { memberString -> UUID in
                    if let uuid = UUID(uuidString: memberString) {
                        return uuid
                    } else {
                        // String bir UUID değilse, bu bir user ID'dir (örn: Firebase UID)
                        // Bu durumda deterministik bir UUID oluşturmak yerine
                        // Bu String'i UUID namespace ile hash'leyebiliriz
                        // Şimdilik basit bir çözüm: yeni UUID oluştur
                        print("Geçersiz UUID formatı: \(memberString), yeni UUID oluşturuluyor")
                        return UUID()
                    }
                }
                
                let newGroup = HikingGroup(
                    id: groupUUID,
                    name: groupName,
                    memberIDs: memberUUIDs
                )
                self?.group = newGroup
                print("Başarıyla gruba katıldınız. Grup: \(groupName), Üye sayısı: \(memberUUIDs.count)")
            }, onFailure: { [weak self] error in
                print("Gruba katılım hatası: \(error.localizedDescription)")
                self?.errorMessage = "Gruba katılım başarısız: \(error.localizedDescription)"
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Helper Methods
    
    private func updateUserLocationInFirestore(_ location: CLLocation) {
        guard let groupId = group?.id.uuidString else { return }
        
        isUpdatingLocation = true
        
        groupService.updateLocation(
            groupId: groupId, 
            userId: currentUserID,
            latitude: location.coordinate.latitude, 
            longitude: location.coordinate.longitude
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onSuccess: { [weak self] in
            self?.isUpdatingLocation = false
        }, onFailure: { [weak self] error in
            self?.isUpdatingLocation = false
            self?.errorMessage = "Konum güncellenemedi: \(error.localizedDescription)"
        })
        .disposed(by: disposeBag)
    }
}

// MARK: - Combine to RxSwift Bridge
// Hata düzeltmesi: Bu extension, herhangi bir Combine Publisher'ını RxSwift Observable'ına çevirir.
extension Publisher {
    func asObservable() -> Observable<Output> {
        return Observable.create { observer in
            let cancellable = self.sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                },
                receiveValue: { value in
                    observer.onNext(value)
                }
            )
            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
}