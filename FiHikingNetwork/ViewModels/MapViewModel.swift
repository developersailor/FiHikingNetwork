import Foundation
import MapKit
import CoreLocation
import SwiftData

@MainActor
class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocations: [UUID: CLLocationCoordinate2D] = [:]
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.92, longitude: 32.85),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled = false
    @Published var locationError: String?
    
    private let locationManager = CLLocationManager()
    private let currentUserID = UUID() // Gerçek uygulamada UserViewModel'den alınacak
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // 10 metre değişimde güncelle
        
        // Sadece gerçek cihazda ve "Always" izni varsa arka plan konum izni etkinleştir
        #if !targetEnvironment(simulator)
        if locationManager.authorizationStatus == .authorizedAlways {
            locationManager.allowsBackgroundLocationUpdates = true
        }
        #endif
        
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func requestLocationPermission() {
        print("🗺️ MapViewModel: Requesting location permission")
        locationAuthorizationStatus = locationManager.authorizationStatus
        
        switch locationAuthorizationStatus {
        case .notDetermined:
            print("🗺️ MapViewModel: Location permission not determined, requesting...")
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ MapViewModel: Location permission granted, starting updates")
            startLocationUpdates()
        case .denied, .restricted:
            print("❌ MapViewModel: Location permission denied")
            locationError = "Konum izni reddedildi. Ayarlardan konum iznini etkinleştirin."
        @unknown default:
            print("⚠️ MapViewModel: Unknown location permission status")
            locationError = "Bilinmeyen konum izni durumu"
        }
    }
    
    func startLocationUpdates() {
        guard CLLocationManager.locationServicesEnabled() else {
            print("❌ MapViewModel: Location services disabled on device")
            locationError = "Konum servisleri devre dışı"
            return
        }
        
        guard locationAuthorizationStatus == .authorizedWhenInUse || 
              locationAuthorizationStatus == .authorizedAlways else {
            print("❌ MapViewModel: No location permission")
            locationError = "Konum izni verilmedi"
            return
        }
        
        print("✅ MapViewModel: Starting location updates")
        locationManager.startUpdatingLocation()
        isLocationEnabled = true
        locationError = nil
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isLocationEnabled = false
    }
    
    func addUserLocation(_ userID: UUID, coordinate: CLLocationCoordinate2D) {
        userLocations[userID] = coordinate
    }
    
    func removeUserLocation(_ userID: UUID) {
        userLocations.removeValue(forKey: userID)
    }
    
    func centerOnUserLocation() {
        guard let userLocation = userLocation else { return }
        
        region = MKCoordinateRegion(
            center: userLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    // MARK: - CLLocationManagerDelegate
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            let coordinate = location.coordinate
            print("🗺️ MapViewModel: Location updated - Lat: \(coordinate.latitude), Lon: \(coordinate.longitude)")
            
            userLocation = coordinate
            
            // Kullanıcının kendi konumunu da userLocations'a ekle
            userLocations[currentUserID] = coordinate
            
            // Harita merkezini kullanıcı konumuna güncelle (sadece ilk kez)
            if region.center.latitude == 39.92 && region.center.longitude == 32.85 {
                print("🗺️ MapViewModel: Centering map on user location")
                region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
            
            // Konum hatasını temizle
            locationError = nil
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationError = "Konum alınamadı: \(error.localizedDescription)"
            print("Konum hatası: \(error.localizedDescription)")
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            print("🗺️ MapViewModel: Location authorization changed to: \(status.rawValue)")
            locationAuthorizationStatus = status
            
            // Arka plan konum iznini güncelle
            #if !targetEnvironment(simulator)
            if status == .authorizedAlways {
                locationManager.allowsBackgroundLocationUpdates = true
                print("✅ MapViewModel: Background location updates enabled")
            } else {
                locationManager.allowsBackgroundLocationUpdates = false
                print("⚠️ MapViewModel: Background location updates disabled")
            }
            #endif
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                print("✅ MapViewModel: Location permission granted, starting updates")
                startLocationUpdates()
            case .denied, .restricted:
                print("❌ MapViewModel: Location permission denied/restricted")
                locationError = "Konum izni reddedildi. Ayarlardan konum iznini etkinleştirin."
                isLocationEnabled = false
            case .notDetermined:
                print("🗺️ MapViewModel: Location permission not determined")
                break
            @unknown default:
                print("⚠️ MapViewModel: Unknown location authorization status")
                locationError = "Bilinmeyen konum izni durumu"
            }
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            locationAuthorizationStatus = manager.authorizationStatus
        }
    }
} 