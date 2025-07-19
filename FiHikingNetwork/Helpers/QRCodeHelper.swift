import Foundation
import CoreImage.CIFilterBuiltins
import SwiftUI

class QRCodeHelper {
    static func generateQRCode(from string: String) -> Image? {
        let data = Data(string.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            let context = CIContext()
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return Image(decorative: cgImage, scale: 1.0)
            }
        }
        return nil
    }
    
    static func decodeQRCode(from ciImage: CIImage) -> String? {
        let context = CIContext()
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: ciImage) as? [CIQRCodeFeature]
        return features?.first?.messageString
    }
}