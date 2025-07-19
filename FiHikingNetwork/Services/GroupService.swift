import FirebaseFirestore
import FirebaseAuth
import RxSwift

class GroupService: BaseService {
    func createGroup(name: String, memberIDs: [String], leaderId: String) -> Single<String> {
        let groupId = UUID().uuidString
        var groupData: [String: Any] = [
            "id": groupId,
            "name": name,
            "leaderId": leaderId // Adding leaderId to comply with Firestore rules
        ]
        // Leader'ı da üye listesine ekle
        var allMembers = memberIDs
        if !allMembers.contains(leaderId) {
            allMembers.append(leaderId)
        }
        groupData["members"] = allMembers
        
        return addDocument(collection: "groups", data: groupData)
            .map { groupId } // Grup ID'sini döndür
    }

    func deleteGroup(groupId: String) -> Single<Void> {
        return deleteDocument(collection: "groups", documentId: groupId)
    }

    func fetchGroup(groupId: String) -> Single<[String: Any]> {
        return fetchDocument(collection: "groups", documentId: groupId)
    }

    func updateLocation(groupId: String, userId: String, latitude: Double, longitude: Double) -> Single<Void> {
        print("🗺️ LocationService: Updating location for user \(userId) in group \(groupId)")
        print("🗺️ LocationService: Coordinates - Lat: \(latitude), Lon: \(longitude)")
        
        let locationData: [String: Any] = [
            "userId": userId,
            "latitude": latitude,
            "longitude": longitude,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        let locationRef = db.collection("groups").document(groupId).collection("memberLocations").document(userId)
        
        return Single.create { observer in
            locationRef.setData(locationData, merge: true) { error in
                if let error = error {
                    print("❌ LocationService: Location update failed - \(error.localizedDescription)")
                    observer(.failure(error))
                } else {
                    print("✅ LocationService: Location updated successfully for user \(userId)")
                    observer(.success(()))
                }
            }
            return Disposables.create()
        }
    }

    func fetchLocations(groupId: String) -> Single<[MemberLocation]> {
        print("🗺️ LocationService: Fetching member locations for group \(groupId)")
        
        return fetchDocuments(collection: "groups/\(groupId)/memberLocations").map { documents in
            let locations = documents.compactMap { data -> MemberLocation? in
                guard let id = data["userId"] as? String,
                      let latitude = data["latitude"] as? Double,
                      let longitude = data["longitude"] as? Double,
                      let timestamp = data["timestamp"] as? Timestamp else {
                    print("⚠️ LocationService: Invalid location data - \(data)")
                    return nil
                }
                return MemberLocation(id: id, latitude: latitude, longitude: longitude, timestamp: timestamp)
            }
            print("✅ LocationService: Found \(locations.count) member locations")
            return locations
        }
    }

    /// Belirtilen grubun konumlarını anlık olarak dinler.
    /// - Parameter groupId: Dinlenecek grubun kimliği.
    /// - Returns: Konum güncellemelerini içeren bir `Observable`.
    func listenForLocationUpdates(groupId: String) -> Observable<[MemberLocation]> {
        print("🔄 LocationService: Starting to listen for location updates in group \(groupId)")
        
        // Firebase Auth durumunu kontrol et
        if let currentUser = Auth.auth().currentUser {
            print("🔄 LocationService: Authenticated user: \(currentUser.uid)")
        } else {
            print("❌ LocationService: No authenticated user found!")
        }
        
        let locationsCollection = db.collection("groups").document(groupId).collection("memberLocations")
        
        return Observable.create { observer in
            let listener = locationsCollection.addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ LocationService: Location listener error - \(error.localizedDescription)")
                    
                    // Firebase Auth hatası mı kontrol et
                    if error.localizedDescription.contains("permissions") || error.localizedDescription.contains("PERMISSION_DENIED") {
                        print("❌ LocationService: Firebase Security Rules hatası - Lütfen Console'da rules'ları kontrol edin")
                        print("❌ LocationService: Grup ID: \(groupId)")
                        if let user = Auth.auth().currentUser {
                            print("❌ LocationService: User ID: \(user.uid)")
                        }
                    }
                    
                    observer.onError(error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ LocationService: No location documents found")
                    observer.onNext([])
                    return
                }
                
                let locations = documents.compactMap { doc -> MemberLocation? in
                    let data = doc.data()
                    guard let latitude = data["latitude"] as? Double,
                          let longitude = data["longitude"] as? Double,
                          let timestamp = data["timestamp"] as? Timestamp else {
                        print("⚠️ LocationService: Invalid location document - \(doc.documentID): \(data)")
                        return nil
                    }
                    return MemberLocation(id: doc.documentID, latitude: latitude, longitude: longitude, timestamp: timestamp)
                }
                
                print("✅ LocationService: Received \(locations.count) location updates")
                observer.onNext(locations)
            }
            
            return Disposables.create {
                listener.remove()
                print("🔄 LocationService: Location listener removed for group \(groupId)")
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
