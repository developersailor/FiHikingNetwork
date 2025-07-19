import SwiftUI
import FirebaseFirestore

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
        // Mevcut kullanıcı ID'sini al
        let currentUserId = groupVM.currentUserID
        
        // UUID formatına çevir
        let currentUserUUID = UUID(uuidString: currentUserId) ?? UUID()
        let newGroup = HikingGroup(
            id: UUID(), 
            name: groupName, 
            memberIDs: [currentUserUUID], // Grup liderini üye listesine ekle
            leaderId: currentUserUUID // Grup lideri bilgisini set et
        )
        
        createdGroup = newGroup
        groupVM.group = newGroup
        showQRCode = true

        // Firebase Firestore'a grup ekleme
        let db = Firestore.firestore()
        let groupRef = db.collection("groups").document(newGroup.id.uuidString)

        let groupData: [String: Any] = [
            "name": newGroup.name,
            "members": newGroup.memberIDs.map { $0.uuidString },
            "leaderId": newGroup.leaderId?.uuidString ?? currentUserId // Grup lideri bilgisini Firebase'e kaydet
        ]

        groupRef.setData(groupData) { error in
            if let error = error {
                print("❌ CreateGroupView: Grup Firestore'a eklenemedi: \(error.localizedDescription)")
            } else {
                print("✅ CreateGroupView: Grup Firestore'a başarıyla eklendi. Lider: \(currentUserId)")
            }
        }
    }
}