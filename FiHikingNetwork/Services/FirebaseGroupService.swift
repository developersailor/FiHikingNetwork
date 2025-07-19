import Foundation
import FirebaseFirestore
import Combine

// MARK: - Firebase Group Service Protocol
@MainActor
protocol GroupServiceProtocol {
    func createGroup(_ group: HikingGroup) -> AnyPublisher<Void, Error>
    func getGroup(id: String) -> AnyPublisher<HikingGroup?, Error>
    func updateGroup(_ group: HikingGroup) -> AnyPublisher<Void, Error>
    func deleteGroup(id: String) -> AnyPublisher<Void, Error>
    func joinGroup(groupId: String, userId: String) -> AnyPublisher<Void, Error>
    func leaveGroup(groupId: String, userId: String) -> AnyPublisher<Void, Error>
    func updateMemberLocation(groupId: String, userId: String, latitude: Double, longitude: Double) -> AnyPublisher<Void, Error>
}

// MARK: - Firebase Group Service Implementation
@MainActor
class FirebaseGroupService: ObservableObject, GroupServiceProtocol {
    private let db = Firestore.firestore()
    
    // MARK: - Create Group
    func createGroup(_ group: HikingGroup) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ServiceError.unknown))
                return
            }
            
            let groupRef = self.db.collection("groups").document(group.id.uuidString)
            
            let groupData: [String: Any] = [
                "id": group.id.uuidString,
                "name": group.name,
                "members": group.memberIDs.map { $0.uuidString },
                "leaderId": group.leaderId?.uuidString ?? "",
                "createdAt": Timestamp(),
                "updatedAt": Timestamp()
            ]
            
            groupRef.setData(groupData) { error in
                if let error = error {
                    print("❌ FirebaseGroupService: Grup oluşturulamadı: \(error.localizedDescription)")
                    promise(.failure(error))
                } else {
                    print("✅ FirebaseGroupService: Grup başarıyla oluşturuldu: \(group.name)")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Get Group
    func getGroup(id: String) -> AnyPublisher<HikingGroup?, Error> {
        Future<HikingGroup?, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ServiceError.unknown))
                return
            }
            
            let groupRef = self.db.collection("groups").document(id)
            
            groupRef.getDocument { document, error in
                if let error = error {
                    print("❌ FirebaseGroupService: Grup getirilemedi: \(error.localizedDescription)")
                    promise(.failure(error))
                    return
                }
                
                guard let document = document, 
                      document.exists,
                      let data = document.data() else {
                    print("⚠️ FirebaseGroupService: Grup bulunamadı: \(id)")
                    promise(.success(nil))
                    return
                }
                
                // Parse group data
                guard let groupId = UUID(uuidString: id),
                      let name = data["name"] as? String,
                      let memberStrings = data["members"] as? [String] else {
                    promise(.failure(ServiceError.invalidData))
                    return
                }
                
                let memberIDs = memberStrings.compactMap { UUID(uuidString: $0) }
                let leaderId = (data["leaderId"] as? String).flatMap { UUID(uuidString: $0) }
                
                let group = HikingGroup(
                    id: groupId,
                    name: name,
                    memberIDs: memberIDs,
                    leaderId: leaderId
                )
                
                print("✅ FirebaseGroupService: Grup başarıyla getirildi: \(name)")
                promise(.success(group))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Update Group
    func updateGroup(_ group: HikingGroup) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ServiceError.unknown))
                return
            }
            
            let groupRef = self.db.collection("groups").document(group.id.uuidString)
            
            let updateData: [String: Any] = [
                "name": group.name,
                "members": group.memberIDs.map { $0.uuidString },
                "leaderId": group.leaderId?.uuidString ?? "",
                "updatedAt": Timestamp()
            ]
            
            groupRef.updateData(updateData) { error in
                if let error = error {
                    print("❌ FirebaseGroupService: Grup güncellenemedi: \(error.localizedDescription)")
                    promise(.failure(error))
                } else {
                    print("✅ FirebaseGroupService: Grup başarıyla güncellendi: \(group.name)")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Delete Group
    func deleteGroup(id: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ServiceError.unknown))
                return
            }
            
            let groupRef = self.db.collection("groups").document(id)
            
            groupRef.delete { error in
                if let error = error {
                    print("❌ FirebaseGroupService: Grup silinemedi: \(error.localizedDescription)")
                    promise(.failure(error))
                } else {
                    print("✅ FirebaseGroupService: Grup başarıyla silindi: \(id)")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Join Group
    func joinGroup(groupId: String, userId: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ServiceError.unknown))
                return
            }
            
            let groupRef = self.db.collection("groups").document(groupId)
            
            groupRef.updateData([
                "members": FieldValue.arrayUnion([userId]),
                "updatedAt": Timestamp()
            ]) { error in
                if let error = error {
                    print("❌ FirebaseGroupService: Gruba katılınamadı: \(error.localizedDescription)")
                    promise(.failure(error))
                } else {
                    print("✅ FirebaseGroupService: Gruba başarıyla katılındı. User: \(userId)")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Leave Group
    func leaveGroup(groupId: String, userId: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ServiceError.unknown))
                return
            }
            
            let groupRef = self.db.collection("groups").document(groupId)
            
            groupRef.updateData([
                "members": FieldValue.arrayRemove([userId]),
                "updatedAt": Timestamp()
            ]) { error in
                if let error = error {
                    print("❌ FirebaseGroupService: Gruptan çıkılamadı: \(error.localizedDescription)")
                    promise(.failure(error))
                } else {
                    print("✅ FirebaseGroupService: Gruptan başarıyla çıkıldı. User: \(userId)")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Update Member Location
    func updateMemberLocation(groupId: String, userId: String, latitude: Double, longitude: Double) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ServiceError.unknown))
                return
            }
            
            let locationRef = self.db.collection("groups")
                .document(groupId)
                .collection("memberLocations")
                .document(userId)
            
            let locationData: [String: Any] = [
                "latitude": latitude,
                "longitude": longitude,
                "timestamp": Timestamp(),
                "userId": userId
            ]
            
            locationRef.setData(locationData) { error in
                if let error = error {
                    print("❌ FirebaseGroupService: Konum güncellenemedi: \(error.localizedDescription)")
                    promise(.failure(error))
                } else {
                    print("✅ FirebaseGroupService: Konum başarıyla güncellendi. User: \(userId)")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Service Errors
enum ServiceError: LocalizedError {
    case unknown
    case invalidData
    case networkError
    case authenticationRequired
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Bilinmeyen hata oluştu"
        case .invalidData:
            return "Geçersiz veri formatı"
        case .networkError:
            return "Ağ bağlantısı hatası"
        case .authenticationRequired:
            return "Kimlik doğrulaması gerekli"
        }
    }
}
