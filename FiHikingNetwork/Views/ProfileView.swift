import SwiftUI

struct ProfileView: View {
    @ObservedObject var userVM: UserViewModel
    @ObservedObject var groupVM: GroupViewModel
    @State private var isEditing = false
    @State private var showQRCode = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Profil")
                .bold()
                .foregroundColor(.primaryGreen)
            Text("İsim: \(userVM.user?.name ?? "-")")
                .foregroundColor(.textColor(for: .primaryGreen))
            Text("Kullanıcı Adı: \(userVM.user?.username ?? "-")")
                .foregroundColor(.textColor(for: .primaryGreen))
            Text("Telefon: \(userVM.user?.phone ?? "-")")
                .foregroundColor(.textColor(for: .primaryGreen))

            if let hikingGroup = groupVM.group {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Aktif Grup")
                        .font(.headline)
                        .padding(.top, 8)
                        .foregroundColor(.earthBrown)
                    Text("Grup Adı: \(hikingGroup.name)")
                    Text("Üye Sayısı: \(hikingGroup.memberIDs.count)")

                    HStack {
                        Button("QR Kodu Göster") {
                            showQRCode = true
                        }
                        .buttonStyle(.bordered)

                        Button("Grubu Sil") {
                            deleteGroup()
                        }
                        .buttonStyle(.borderedProminent)
                        .foregroundColor(.red)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.skyBlue.opacity(0.1)))
            }

            Button("Profili Düzenle") {
                isEditing = true
            }
            .sheet(isPresented: $isEditing) {
                EditProfileView(userVM: userVM, isPresented: $isEditing)
            }
        }
        .padding()
        .background(Color.naturalBeige)
        .padding(.horizontal)
        .sheet(isPresented: $showQRCode) {
            if let hikingGroup = groupVM.group {
                QRCodeDisplayView(hikingGroup: hikingGroup, isPresented: $showQRCode)
            }
        }
    }

    private func deleteGroup() {
        groupVM.group = nil
    }
}