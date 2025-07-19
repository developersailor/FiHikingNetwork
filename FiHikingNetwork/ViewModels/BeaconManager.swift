import Foundation
import CoreLocation
import Combine

class BeaconManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var nearbyBeacons: [BeaconInfo] = []
    var groupMemberUUIDs: [UUID] = [] // Grup üyelerinin UUID'lerini tutan bir liste

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }

    func startScanning() {
        let beaconRegion = CLBeaconRegion(
            uuid: UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!,
            identifier: "FiHikingNetworkRegion"
        )
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
    }

    func stopScanning() {
        let beaconRegion = CLBeaconRegion(
            uuid: UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!,
            identifier: "FiHikingNetworkRegion"
        )
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
    }

    func locationManager(
        _ manager: CLLocationManager,
        didRange beacons: [CLBeacon],
        satisfying constraint: CLBeaconIdentityConstraint
    ) {
        nearbyBeacons = beacons.compactMap { beacon in
            guard let major = CLBeaconMajorValue(exactly: beacon.major),
                  let minor = CLBeaconMinorValue(exactly: beacon.minor),
                  groupMemberUUIDs.contains(beacon.uuid) else {
                return nil
            }
            return BeaconInfo(
                id: UUID(),
                uuid: beacon.uuid,
                major: major,
                minor: minor,
                proximity: beacon.proximity
            )
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Location Manager Error: \(error.localizedDescription)")
    }
    
    func updateGroupMembers(with uuids: [UUID]) {
        groupMemberUUIDs = uuids
    }
}