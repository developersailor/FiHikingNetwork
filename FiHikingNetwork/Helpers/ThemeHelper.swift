import SwiftUI

// Renk tanımlamaları kaldırıldı, çakışma giderildi.

extension Color {
    static func textColor(for backgroundColor: Color) -> Color {
        switch backgroundColor {
        case .primaryGreen, .skyBlue, .earthBrown:
            return Color(red: 0.0, green: 0.0, blue: 0.5) // Lacivert
        case .naturalBeige:
            return .black
        default:
            return .black
        }
    }
}