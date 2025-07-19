import SwiftUI
import FirebaseAuth

struct OnboardingView: View {
    @EnvironmentObject var appViewModel: AppViewModel
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
                    .padding(.top, 40)
                
                VStack(spacing: 15) {
                    TextField("İsim", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("Kullanıcı Adı", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("Telefon", text: $phone)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.phonePad)
                        .padding(.horizontal)
                }
                
                Button("Profil Oluştur") {
                    createProfile()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || username.isEmpty || phone.isEmpty)
                .padding(.horizontal)
                
                Button("Atla") {
                    skipProfileCreation()
                }
                .foregroundColor(.gray)
                
                Spacer()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Eksik Bilgi"), message: Text("Lütfen tüm alanları doldurun."), dismissButton: .default(Text("Tamam")))
            }
        } else {
            AuthView(isAuthenticated: $isAuthenticated)
                .onAppear {
                    // Authentication durumunu kontrol et
                    isAuthenticated = Auth.auth().currentUser != nil
                }
        }
    }
    
    private func createProfile() {
        guard !name.isEmpty, !username.isEmpty, !phone.isEmpty else {
            showAlert = true
            return
        }
        
        guard Auth.auth().currentUser != nil else {
            print("❌ Current user not found")
            return
        }
        
        let newUser = User(id: UUID(), name: name, username: username, phone: phone)
        userVM.updateUser(newUser)
        
        // Profil oluşturulduktan sonra AppViewModel'e haber ver
        print("✅ Profile created, notifying AppViewModel")
        appViewModel.setUserProfileCreated()
    }
    
    private func skipProfileCreation() {
        guard Auth.auth().currentUser != nil else {
            print("❌ Current user not found")
            return
        }
        
        let emptyUser = User(id: UUID(), name: "Kullanıcı", username: "user_\(UUID().uuidString.prefix(6))", phone: "")
        userVM.updateUser(emptyUser)
        
        print("✅ Profile skipped, notifying AppViewModel")
        appViewModel.setUserProfileCreated()
    }
}