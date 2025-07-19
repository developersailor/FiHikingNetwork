import SwiftUI

struct CreateGroupView: View {
    @ObservedObject var groupVM: GroupViewModel
    @Binding var isPresented: Bool
    @State private var groupName = ""
    @State private var showQRCode = false
    @State private var createdGroup: HikingGroup?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let hikingGroup = createdGroup, showQRCode {
                    VStack(spacing: 16) {
                        Text("Grup Oluşturuldu!")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primaryGreen)
                        if let qrImage = QRCodeHelper.generateQRCode(from: hikingGroup.id.uuidString) {
                            qrImage
                                .resizable()
                                .frame(width: 200, height: 200)
                        }
                        Text("QR Kodu Paylaşın")
                            .font(.headline)
                            .foregroundColor(.earthBrown)
                        Text("Diğer kullanıcılar bu QR kodu okutarak gruba katılabilir.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                } else {
                    VStack(spacing: 16) {
                        Text("Yeni Grup Oluştur")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primaryGreen)
                        TextField("Grup Adı", text: $groupName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Grup Oluştur") {
                            createGroup()
                        }
                        .buttonStyle(.borderedProminent)
                        .background(Color.skyBlue)
                        .foregroundColor(.white)
                        .disabled(groupName.isEmpty)
                    }
                }
                Spacer()
            }
            .padding()
            .background(Color.naturalBeige)
            .navigationTitle("Grup Oluştur")
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
    
    private func createGroup() {
        // GroupViewModel'deki Firebase service metodunu kullan
        groupVM.createGroup(name: groupName)
        
        // UI state'i güncelle
        let currentUserId = groupVM.currentUserID
        let currentUserUUID = UUID(uuidString: currentUserId) ?? UUID()
        
        let newGroup = HikingGroup(
            id: UUID(),
            name: groupName,
            memberIDs: [currentUserUUID],
            leaderId: currentUserUUID
        )
        
        createdGroup = newGroup
        showQRCode = true
        
        print("✅ CreateGroupView: Grup oluşturma UI'da tamamlandı: \(groupName)")
    }
}