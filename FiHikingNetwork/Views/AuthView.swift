import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @Binding var isAuthenticated: Bool

    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Picker("Mode", selection: $isLoginMode) {
                    Text("Giriş Yap").tag(true)
                    Text("Kayıt Ol").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                TextField("E-posta", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Parola", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button(action: handleAuthAction) {
                    Text(isLoginMode ? "Giriş Yap" : "Kayıt Ol")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryGreen)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: signInAnonymously) {
                    Text("Anonim Giriş")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Spacer()
            }
            .padding()
            .background(Color.naturalBeige)
            .navigationTitle(isLoginMode ? "Giriş Yap" : "Kayıt Ol")
        }
    }

    private func handleAuthAction() {
        if isLoginMode {
            loginUser()
        } else {
            registerUser()
        }
    }

    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = "Giriş başarısız: \(error.localizedDescription)"
                return
            }
            self.errorMessage = nil
            print("Giriş başarılı: \(result?.user.email ?? "")")
            isAuthenticated = true
        }
    }

    private func registerUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = "Kayıt başarısız: \(error.localizedDescription)"
                return
            }
            self.errorMessage = nil
            print("Kayıt başarılı: \(result?.user.email ?? "")")
            isAuthenticated = true
        }
    }

    private func signInAnonymously() {
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                self.errorMessage = "Anonim giriş başarısız: \(error.localizedDescription)"
                return
            }
            self.errorMessage = nil
            print("Anonim giriş başarılı: \(result?.user.uid ?? "")")
            isAuthenticated = true
        }
    }
}
