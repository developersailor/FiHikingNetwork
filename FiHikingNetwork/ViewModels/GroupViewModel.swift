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
        groupService.createGroup(name: name, memberIDs: memberIDs, leaderId: currentUserID)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: {
                print("Grup başarıyla oluşturuldu.")
            }, onFailure: { [weak self] error in
                self?.errorMessage = "Grup oluşturulamadı: \(error.localizedDescription)"
            })
            .disposed(by: disposeBag)
    }
    
    /// Kullanıcıyı belirtilen gruba dahil eder.
    /// - Parameter groupId: Katılınacak grubun kimliği.
    func joinGroup(groupId: String) {
        groupService.addMemberToGroup(userId: currentUserID, to: groupId)
            .flatMap { [unowned self] () -> Single<[String: Any]> in // Hata düzeltmesi: andThen yerine flatMap kullanıldı.
                // Üye ekleme başarılı olduktan sonra, güncel grup bilgisini çekiyoruz.
                return self.groupService.fetchGroup(groupId: groupId)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] groupData in
                // Firestore'dan gelen veriyi local HikingGroup modeline çevir
                let newGroup = HikingGroup(
                    id: UUID(uuidString: groupData["id"] as? String ?? "") ?? UUID(),
                    name: groupData["name"] as? String ?? "Bilinmeyen Grup",
                    memberIDs: (groupData["members"] as? [String] ?? []).compactMap { UUID(uuidString: $0) }
                )
                self?.group = newGroup
                print("Başarıyla gruba katıldınız ve grup bilgisi güncellendi.")
            }, onFailure: { [weak self] error in
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