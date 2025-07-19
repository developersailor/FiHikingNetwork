import Foundation
import SwiftData

@Model
final class HikingGroup: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var memberIDs: [UUID]
    
    init(id: UUID = UUID(), name: String, memberIDs: [UUID] = []) {
        self.id = id
        self.name = name
        self.memberIDs = memberIDs
    }
} 
