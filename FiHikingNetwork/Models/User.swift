import Foundation
import SwiftData

@Model
final class User: Identifiable, Codable {
    @Attribute(.unique) var id: UUID
    var name: String
    var username: String
    var phone: String
    
    init(id: UUID = UUID(), name: String, username: String, phone: String) {
        self.id = id
        self.name = name
        self.username = username
        self.phone = phone
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case username
        case phone
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.username = try container.decode(String.self, forKey: .username)
        self.phone = try container.decode(String.self, forKey: .phone)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(username, forKey: .username)
        try container.encode(phone, forKey: .phone)
    }
}