import Foundation
import CoreLocation

public struct BeaconInfo: Identifiable, Codable {
    public let id: UUID
    public var uuid: UUID
    public var major: CLBeaconMajorValue
    public var minor: CLBeaconMinorValue
    public var proximity: CLProximity?

    enum CodingKeys: String, CodingKey {
        case id, uuid, major, minor, proximity
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(major, forKey: .major)
        try container.encode(minor, forKey: .minor)
        if let proximity = proximity {
            try container.encode(proximity.rawValue, forKey: .proximity)
        } else {
            try container.encodeNil(forKey: .proximity)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        uuid = try container.decode(UUID.self, forKey: .uuid)
        major = try container.decode(CLBeaconMajorValue.self, forKey: .major)
        minor = try container.decode(CLBeaconMinorValue.self, forKey: .minor)
        if let proximityRaw = try? container.decode(Int.self, forKey: .proximity) {
            proximity = CLProximity(rawValue: proximityRaw)
        } else {
            proximity = nil
        }
    }

    public init(id: UUID, uuid: UUID, major: CLBeaconMajorValue, minor: CLBeaconMinorValue, proximity: CLProximity?) {
        self.id = id
        self.uuid = uuid
        self.major = major
        self.minor = minor
        self.proximity = proximity
    }
} 