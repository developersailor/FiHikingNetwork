import SwiftUI

struct QRCodeDisplayView: View {
    let hikingGroup: HikingGroup
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Grup QR Kodu")
                    .font(.title2)
                    .bold()
                
                if let qrImage = QRCodeHelper.generateQRCode(from: hikingGroup.id.uuidString) {
                    qrImage
                        .resizable()
                        .frame(width: 250, height: 250)
                        .padding()
                } else {
                    Text("QR Kod oluşturulamadı")
                        .foregroundColor(.red)
                }
                
                VStack(spacing: 8) {
                    Text("Grup: \(hikingGroup.name)")
                        .font(.headline)
                    Text("QR Kodu Paylaşın")
                        .font(.subheadline)
                    Text("Diğer kullanıcılar bu QR kodu okutarak gruba katılabilir.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("QR Kod")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        isPresented = false
                    }
                }
            }
        }
    }
} 