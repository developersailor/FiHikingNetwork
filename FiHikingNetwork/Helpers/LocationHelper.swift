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
    
    // MARK: - User Input Validation with Regex
    
    /// Kullanıcıdan alınan koordinat string'ini regex ile doğrular
    /// Format: "41.0082,28.9784" veya "41.0082, 28.9784"
    /// - Parameter coordinateString: Kullanıcının girdiği koordinat string'i
    /// - Returns: String geçerliyse true
    static func validateCoordinateString(_ coordinateString: String) -> Bool {
        let pattern = #"^-?\d{1,3}(\.\d+)?,\s*-?\d{1,3}(\.\d+)?$"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: coordinateString.utf16.count)
        return regex?.firstMatch(in: coordinateString, options: [], range: range) != nil
    }
    
    /// Koordinat string'ini CLLocationCoordinate2D'ye çevirir
    /// - Parameter coordinateString: "lat,lon" formatında string
    /// - Returns: Başarılıysa koordinat, değilse nil
    static func parseCoordinateString(_ coordinateString: String) -> CLLocationCoordinate2D? {
        guard validateCoordinateString(coordinateString) else { return nil }
        
        let components = coordinateString.replacingOccurrences(of: " ", with: "").split(separator: ",")
        guard components.count == 2,
              let lat = Double(components[0]),
              let lon = Double(components[1]) else {
            return nil
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        return isValidCoordinate(coordinate) ? coordinate : nil
    }
    
    /// Grup adını regex ile doğrular (sadece harf, rakam, boşluk ve tire)
    /// - Parameter groupName: Grup adı
    /// - Returns: Ad geçerliyse true
    static func validateGroupName(_ groupName: String) -> Bool {
        let pattern = #"^[a-zA-ZğĞıİöÖüÜşŞçÇ0-9\s\-]{2,30}$"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: groupName.utf16.count)
        return regex?.firstMatch(in: groupName, options: [], range: range) != nil
    }
    
    /// Kullanıcı adını regex ile doğrular (alfanumerik ve alt çizgi)
    /// - Parameter username: Kullanıcı adı
    /// - Returns: Ad geçerliyse true
    static func validateUsername(_ username: String) -> Bool {
        let pattern = #"^[a-zA-Z0-9_]{3,20}$"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: username.utf16.count)
        return regex?.firstMatch(in: username, options: [], range: range) != nil
    }
    
    /// Email adresini regex ile doğrular
    /// - Parameter email: Email adresi
    /// - Returns: Email geçerliyse true
    static func validateEmail(_ email: String) -> Bool {
        let pattern = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: email.utf16.count)
        return regex?.firstMatch(in: email, options: [], range: range) != nil
    }
    
    /// Telefon numarasını regex ile doğrular (Türkiye formatı)
    /// Format: +90XXXXXXXXXX veya 05XXXXXXXXX
    /// - Parameter phoneNumber: Telefon numarası
    /// - Returns: Numara geçerliyse true
    static func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        let pattern = #"^(\+90|0)?5[0-9]{9}$"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: phoneNumber.utf16.count)
        return regex?.firstMatch(in: phoneNumber, options: [], range: range) != nil
    }
    
    /// Mesafe değerini string'den parse eder ve doğrular
    /// Format: "1000m", "2.5km", "100"
    /// - Parameter distanceString: Mesafe string'i
    /// - Returns: Metre cinsinden mesafe, geçersizse nil
    static func parseDistanceString(_ distanceString: String) -> CLLocationDistance? {
        let pattern = #"^(\d+(?:\.\d+)?)\s*(m|km|meter|kilometre)?$"#
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: distanceString.utf16.count)
        
        guard let match = regex?.firstMatch(in: distanceString, options: [], range: range) else {
            return nil
        }
        
        let numberRange = Range(match.range(at: 1), in: distanceString)
        let unitRange = Range(match.range(at: 2), in: distanceString)
        
        guard let numberRange = numberRange,
              let distance = Double(String(distanceString[numberRange])) else {
            return nil
        }
        
        if let unitRange = unitRange {
            let unit = String(distanceString[unitRange]).lowercased()
            if unit.contains("km") || unit.contains("kilometre") {
                return distance * 1000
            }
        }
        
        return distance
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