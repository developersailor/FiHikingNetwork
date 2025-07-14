//
//  Item.swift
//  FiHikingNetwork
//
//  Created by Mehmet Fışkındal on 14.07.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
