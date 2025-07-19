import Foundation
import CoreLocation
import Combine
import RxSwift
import RxCocoa
import FirebaseFirestore

/// Grup yönetimi, konum güncellemeleri ve Firebase etkileşimlerini yöneten ViewModel.
@MainActor
class GroupViewModel: ObservableObject {
    
    // MARK: - Published Properties for SwiftUI
    @Published var group: HikingGroup?
    @Published var memberLocations: [MemberLocation] = []
    @Published var errorMessage: String?
    @Published var isUpdatingLocation = false
    @Published var isLoading = false
    @Published var isCreatingGroup = false
    @Published var isJoiningGroup = false
    
    // MARK: - Private Properties
    private let firebaseGroupService: GroupServiceProtocol
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    private let disposeBag = DisposeBag()
    
    // Mevcut kullanıcı kimliği. View'ın erişebilmesi için 'private' değil.
    let currentUserID: String
    
    // MARK: - Initializer
    init(group: HikingGroup? = nil,
         currentUserID: String,
         firebaseGroupService: GroupServiceProtocol? = nil,
         locationManager: LocationManager? = nil) {
        self.group = group
        self.currentUserID = currentUserID
        self.firebaseGroupService = firebaseGroupService ?? FirebaseGroupService()
        self.locationManager = locationManager ?? LocationManager()
        
        print("🔧 GroupViewModel initialized with UserID: \(currentUserID)")
        setupLocationUpdates()
    }
    
    // MARK: - Location Setup
    private func setupLocationUpdates() {
        // RxSwift'den gelen konum güncellemelerini dinle ve Firebase'e yaz
        locationManager.locationUpdates
            .debounce(.seconds(15), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] location in
                Task {
                    await self?.updateUserLocationInFirebase(location)
                }
            })
            .disposed(by: disposeBag)
        
        // Grup değişimlerini dinle ve üye konumlarını güncelle
        $group
            .compactMap { $0?.id.uuidString }
            .removeDuplicates()
            .sink { [weak self] groupId in
                Task {
                    await self?.startListeningToMemberLocations(groupId: groupId)
                }
            }
            .store(in: &cancellables)
    }
    
    private func startListeningToMemberLocations(groupId: String) async {
        // Firebase real-time listener ile üye konumlarını dinle
        // Bu kısım FirebaseGroupService'in real-time listener method'u ile implement edilecek
        print("📍 Starting to listen member locations for group: \(groupId)")
    }
    
    // MARK: - Public Methods
    
    func startLocationTracking() {
        locationManager.requestLocationPermission()
    }
    
    func stopLocationTracking() {
        locationManager.stopLocationUpdates()
    }
    
    // MARK: - Firebase Group Operations
    
    /// Yeni grup oluşturur
    /// - Parameter name: Grup adı
    func createGroup(name: String) {
        guard !name.isEmpty else {
            errorMessage = "Grup adı boş olamaz"
            return
        }
        
        isCreatingGroup = true
        isLoading = true
        errorMessage = nil
        
        // Mevcut kullanıcı UUID'ye çevir
        let currentUserUUID = UUID(uuidString: currentUserID) ?? UUID()
        
        // Yeni grup oluştur
        let newGroup = HikingGroup(
            id: UUID(),
            name: name,
            memberIDs: [currentUserUUID],
            leaderId: currentUserUUID
        )
        
        // Firebase'e kaydet - Combine ile
        firebaseGroupService.createGroup(newGroup)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isCreatingGroup = false
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Grup oluşturulamadı: \(error.localizedDescription)"
                        print("❌ Grup oluşturma hatası: \(error)")
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.group = newGroup
                    print("✅ Grup başarıyla oluşturuldu: \(name)")
                }
            )
            .store(in: &cancellables)
    }
    
    /// Gruba katılır
    /// - Parameter groupId: Grup ID'si
    func joinGroup(groupId: String) {
        guard !groupId.isEmpty else {
            errorMessage = "Grup ID boş olamaz"
            return
        }
        
        isJoiningGroup = true
        isLoading = true
        errorMessage = nil
        
        let currentUserID = self.currentUserID // String olarak kullan
        
        firebaseGroupService.joinGroup(groupId: groupId, userId: currentUserID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isJoiningGroup = false
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Gruba katılamadı: \(error.localizedDescription)"
                        print("❌ Gruba katılma hatası: \(error)")
                    }
                },
                receiveValue: { [weak self] _ in
                    // Grup join edildiğinde grubu yeniden yükle
                    self?.getGroup(groupId: groupId)
                    print("✅ Gruba başarıyla katıldı: \(groupId)")
                }
            )
            .store(in: &cancellables)
    }
    
    /// Gruptan ayrılır
    func leaveGroup() {
        guard let currentGroup = group else {
            errorMessage = "Aktif grup bulunamadı"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let currentUserID = self.currentUserID // String olarak kullan
        
        firebaseGroupService.leaveGroup(groupId: currentGroup.id.uuidString, userId: currentUserID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Gruptan ayrılamadı: \(error.localizedDescription)"
                        print("❌ Gruptan ayrılma hatası: \(error)")
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.group = nil
                    self?.memberLocations = []
                    print("✅ Gruptan başarıyla ayrıldı")
                }
            )
            .store(in: &cancellables)
    }
    
    /// Belirtilen grup ID'sine sahip grubu getirir
    /// - Parameter groupId: Grup ID'si
    func getGroup(groupId: String) {
        guard !groupId.isEmpty else {
            errorMessage = "Grup ID boş olamaz"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        firebaseGroupService.getGroup(id: groupId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Grup getirilemedi: \(error.localizedDescription)"
                        print("❌ Grup getirme hatası: \(error)")
                    }
                },
                receiveValue: { [weak self] fetchedGroup in
                    self?.group = fetchedGroup
                    print("✅ Grup başarıyla getirildi: \(groupId)")
                }
            )
            .store(in: &cancellables)
    }
    
    /// Kullanıcının konumunu günceller
    /// - Parameters:
    ///   - latitude: Enlem
    ///   - longitude: Boylam
    func updateUserLocation(latitude: Double, longitude: Double) {
        guard let currentGroup = group else {
            print("⚠️ Aktif grup yok, konum güncellemesi yapılmadı")
            return
        }
        
        isUpdatingLocation = true
        
        let currentUserID = self.currentUserID // String olarak kullan
        
        firebaseGroupService.updateMemberLocation(
            groupId: currentGroup.id.uuidString,
            userId: currentUserID,
            latitude: latitude,
            longitude: longitude
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isUpdatingLocation = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = "Konum güncellenemedi: \(error.localizedDescription)"
                    print("❌ Konum güncelleme hatası: \(error)")
                }
            },
            receiveValue: { _ in
                print("✅ Kullanıcı konumu güncellendi: \(latitude), \(longitude)")
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Private Helpers
    
    private func updateUserLocationInFirebase(_ location: CLLocation) async {
        updateUserLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
}