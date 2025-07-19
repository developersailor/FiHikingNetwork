import Foundation
import CoreLocation

/// Konum hesaplamaları ve yardımcı fonksiyonlar için utility sınıfı
struct LocationHelper {
    
    /// İki koordinat arasındaki mesafeyi hesaplar
    /// - Parameters:
    ///   - coord1: İlk koordinat
    ///   - coord2: İkinci koordinat
    /// - Returns: Metre cinsinden mesafe
    static func distanceBetween(_ coord1: CLLocationCoordinate2D, _ coord2: CLLocationCoordinate2D) -> CLLocationDistance {
        let loc1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let loc2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
        return loc1.distance(from: loc2)
    }
    
    /// Koordinatın geçerli olup olmadığını kontrol eder
    /// - Parameter coordinate: Kontrol edilecek koordinat
    /// - Returns: Koordinat geçerliyse true
    static func isValidCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return coordinate.latitude >= -90 && coordinate.latitude <= 90 &&
               coordinate.longitude >= -180 && coordinate.longitude <= 180
    }
    
    /// Mesafeyi okunabilir formata çevirir
    /// - Parameter distance: Metre cinsinden mesafe
    /// - Returns: Formatlanmış mesafe string'i
    static func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            let km = distance / 1000
            return String(format: "%.1fkm", km)
        }
    }
    
    /// İki koordinat arasındaki yönü hesaplar
    /// - Parameters:
    ///   - from: Başlangıç koordinatı
    ///   - to: Hedef koordinatı
    /// - Returns: Derece cinsinden yön (0-360)
    static func bearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude.radians
        let lat2 = to.latitude.radians
        let deltaLon = (to.longitude - from.longitude).radians
        
        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        let bearing = atan2(y, x)
        
        return bearing.degrees
    }
    
    /// Koordinatın belirli bir alan içinde olup olmadığını kontrol eder
    /// - Parameters:
    ///   - coordinate: Kontrol edilecek koordinat
    ///   - center: Merkez koordinat
    ///   - radius: Yarıçap (metre)
    /// - Returns: Koordinat alan içindeyse true
    static func isCoordinateInRadius(_ coordinate: CLLocationCoordinate2D, 
                                   center: CLLocationCoordinate2D, 
                                   radius: CLLocationDistance) -> Bool {
        let distance = distanceBetween(coordinate, center)
        return distance <= radius
    }
}

// MARK: - Extensions

extension Double {
    var radians: Double {
        return self * .pi / 180
    }
    
    var degrees: Double {
        return self * 180 / .pi
    }
} 