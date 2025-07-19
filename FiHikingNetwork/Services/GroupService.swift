import FirebaseFirestore
import RxSwift

class GroupService: BaseService {
    func createGroup(name: String, memberIDs: [String], leaderId: String) -> Single<Void> {
        let groupId = UUID().uuidString
        var groupData: [String: Any] = [
            "id": groupId,
            "name": name,
            "leaderId": leaderId // Adding leaderId to comply with Firestore rules
        ]
        groupData["members"] = memberIDs
        return addDocument(collection: "groups", data: groupData)
    }

    func deleteGroup(groupId: String) -> Single<Void> {
        return deleteDocument(collection: "groups", documentId: groupId)
    }

    func fetchGroup(groupId: String) -> Single<[String: Any]> {
        return fetchDocument(collection: "groups", documentId: groupId)
    }

    func updateLocation(groupId: String, userId: String, latitude: Double, longitude: Double) -> Single<Void> {
        let locationData: [String: Any] = [
            "userId": userId,
            "latitude": latitude,
            "longitude": longitude,
            "timestamp": FieldValue.serverTimestamp()
        ]
        return addDocument(collection: "groups/\(groupId)/locations", data: locationData)
    }

    func fetchLocations(groupId: String) -> Single<[MemberLocation]> {
        return fetchDocuments(collection: "groups/\(groupId)/locations").map { documents in
            documents.compactMap { data -> MemberLocation? in
                guard let id = data["userId"] as? String,
                      let latitude = data["latitude"] as? Double,
                      let longitude = data["longitude"] as? Double,
                      let timestamp = data["timestamp"] as? Timestamp else {
                    return nil
                }
                return MemberLocation(id: id, latitude: latitude, longitude: longitude, timestamp: timestamp)
            }
        }
    }

    /// Belirtilen grubun konumlarını anlık olarak dinler.
    /// - Parameter groupId: Dinlenecek grubun kimliği.
    /// - Returns: Konum güncellemelerini içeren bir `Observable`.
    func listenForLocationUpdates(groupId: String) -> Observable<[MemberLocation]> {
        let locationsCollection = db.collection("groups/\(groupId)/locations")
        
        return Observable.create { observer in
            let listener = locationsCollection.addSnapshotListener { snapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    observer.onNext([])
                    return
                }
                
                let locations = documents.compactMap { doc -> MemberLocation? in
                    let data = doc.data()
                    guard let latitude = data["latitude"] as? Double,
                          let longitude = data["longitude"] as? Double,
                          let timestamp = data["timestamp"] as? Timestamp else {
                        return nil
                    }
                    return MemberLocation(id: doc.documentID, latitude: latitude, longitude: longitude, timestamp: timestamp)
                }
                
                observer.onNext(locations)
            }
            
            return Disposables.create {
                listener.remove()
            }
        }
    }

    /// Belirtilen kullanıcıyı bir gruba üye olarak ekler.
    /// - Parameters:
    ///   - userId: Eklenecek kullanıcının kimliği.
    ///   - groupId: Kullanıcının ekleneceği grubun kimliği.
    /// - Returns: İşlemin tamamlandığını bildiren bir `Single`.
    func addMemberToGroup(userId: String, to groupId: String) -> Single<Void> {
        let groupRef = db.collection("groups").document(groupId)
        
        return Single.create { single in
            // FieldValue.arrayUnion, belirtilen eleman dizide yoksa ekler.
            // Bu, aynı üyenin tekrar eklenmesini önler.
            groupRef.updateData([
                "members": FieldValue.arrayUnion([userId])
            ]) { error in
                if let error = error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
}
