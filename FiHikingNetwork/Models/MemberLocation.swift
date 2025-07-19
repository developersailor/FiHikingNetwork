import Foundation
import FirebaseFirestore
import CoreLocation

/// Firestore'daki bir üyenin konum verisini temsil eden model.
struct MemberLocation: Codable, Identifiable {
    /// Belge kimliği, genellikle kullanıcı kimliği (userId) ile aynıdır.
    var id: String
    
    /// Üyenin enlem bilgisi.
    let latitude: Double
    
    /// Üyenin boylam bilgisi.
    let longitude: Double
    
    /// Konum bilgisinin sunucudaki zaman damgası.
    let timestamp: Timestamp
    
    /// Harita üzerinde kullanılmak üzere CLLocationCoordinate2D nesnesi oluşturur.
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case latitude
        case longitude
        case timestamp
    }
}
