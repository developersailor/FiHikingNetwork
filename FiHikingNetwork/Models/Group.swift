import Foundation
import SwiftData

@Model
final class HikingGroup: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var memberIDs: [UUID]
    var leaderId: UUID? // Grup lideri ID'si eklendi
    
    init(id: UUID = UUID(), name: String, memberIDs: [UUID] = [], leaderId: UUID? = nil) {
        self.id = id
        self.name = name
        self.memberIDs = memberIDs
        self.leaderId = leaderId
    }
} 
