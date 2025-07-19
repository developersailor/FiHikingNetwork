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
        locationAuthorizationStatus = locationManager.authorizationStatus
        
        switch locationAuthorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            locationError = "Konum izni reddedildi. Ayarlardan konum iznini etkinleştirin."
        @unknown default:
            locationError = "Bilinmeyen konum izni durumu"
        }
    }
    
    func startLocationUpdates() {
        guard CLLocationManager.locationServicesEnabled() else {
            locationError = "Konum servisleri devre dışı"
            return
        }
        
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
            userLocation = coordinate
            
            // Kullanıcının kendi konumunu da userLocations'a ekle
            userLocations[currentUserID] = coordinate
            
            // Harita merkezini kullanıcı konumuna güncelle (sadece ilk kez)
            if region.center.latitude == 39.92 && region.center.longitude == 32.85 {
                region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
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
            locationAuthorizationStatus = status
            
            // Arka plan konum iznini güncelle
            #if !targetEnvironment(simulator)
            if status == .authorizedAlways {
                locationManager.allowsBackgroundLocationUpdates = true
            } else {
                locationManager.allowsBackgroundLocationUpdates = false
            }
            #endif
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                startLocationUpdates()
            case .denied, .restricted:
                locationError = "Konum izni reddedildi. Ayarlardan konum iznini etkinleştirin."
                isLocationEnabled = false
            case .notDetermined:
                break
            @unknown default:
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