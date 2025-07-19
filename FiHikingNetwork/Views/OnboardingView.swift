import SwiftUI
import FirebaseAuth

struct OnboardingView: View {
    @ObservedObject var userVM: UserViewModel
    @State private var name = ""
    @State private var username = ""
    @State private var phone = ""
    @State private var showAlert = false
    @State private var isAuthenticated = false

    var body: some View {
        if isAuthenticated {
            VStack(spacing: 20) {
                Text("Profil Oluştur")
                    .font(.largeTitle)
                    .bold()
                TextField("İsim", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Kullanıcı Adı", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Telefon", text: $phone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Kaydet") {
                    if name.isEmpty || username.isEmpty || phone.isEmpty {
                        showAlert = true
                    } else {
                        let newUser = User(id: UUID(), name: name, username: username, phone: phone)
                        userVM.updateUser(newUser)
                    }
                }
                .buttonStyle(.borderedProminent)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Eksik Bilgi"), message: Text("Lütfen tüm alanları doldurun."), dismissButton: .default(Text("Tamam")))
                }
            }
            .padding()
        } else {
            AuthView(isAuthenticated: $isAuthenticated)
                .onDisappear {
                    isAuthenticated = Auth.auth().currentUser != nil
                }
        }
    }
}