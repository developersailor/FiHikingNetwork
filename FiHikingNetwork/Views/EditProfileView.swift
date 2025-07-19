import SwiftUI

struct EditProfileView: View {
    @ObservedObject var userVM: UserViewModel
    @Binding var isPresented: Bool
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var phone: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Profili Düzenle")
                .font(.title2)
                .bold()
            TextField("İsim", text: $name)
            TextField("Kullanıcı Adı", text: $username)
            TextField("Telefon", text: $phone)
            Button("Kaydet") {
                let updatedUser = User(id: userVM.user?.id ?? UUID(), name: name, username: username, phone: phone)
                userVM.updateUser(updatedUser)
                isPresented = false
            }
            .buttonStyle(.borderedProminent)
            Button("İptal") {
                isPresented = false
            }
        }
        .padding()
        .onAppear {
            name = userVM.user?.name ?? ""
            username = userVM.user?.username ?? ""
            phone = userVM.user?.phone ?? ""
        }
    }
} 