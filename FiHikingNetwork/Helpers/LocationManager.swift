import Foundation
import CoreLocation
import RxSwift

/// Konum yönetimi için ana sınıf
class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let locationManager = CLLocationManager()
    private let disposeBag = DisposeBag()
    
    // Location updates
    private let locationSubject = PublishSubject<CLLocation>()
    private let authorizationSubject = PublishSubject<CLAuthorizationStatus>()
    private let errorSubject = PublishSubject<Error>()
    
    // Public observables
    var locationUpdates: Observable<CLLocation> {
        return locationSubject.asObservable()
    }
    
    var authorizationStatus: Observable<CLAuthorizationStatus> {
        return authorizationSubject.asObservable()
    }
    
    var locationErrors: Observable<Error> {
        return errorSubject.asObservable()
    }
    
    // Current location
    @Published var currentLocation: CLLocation?
    @Published var isLocationAvailable = false
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // 10 metre
        
        // Initial authorization check
        authorizationSubject.onNext(locationManager.authorizationStatus)
    }
    
    // MARK: - Public Methods
    
    /// Konum izni ister
    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Kullanıcıyı ayarlara yönlendir
            break
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    /// Konum güncellemelerini başlatır
    func startLocationUpdates() {
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        locationManager.startUpdatingLocation()
        isLocationAvailable = true
    }
    
    /// Konum güncellemelerini durdurur
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isLocationAvailable = false
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationSubject.onNext(manager.authorizationStatus)
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startLocationUpdates()
            case .denied, .restricted:
                self.stopLocationUpdates()
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location
            self.locationSubject.onNext(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorSubject.onNext(error)
        }
    }
}
