import SwiftUI

struct EditProfileView: View {
    @ObservedObject var userVM: UserViewModel
    @Binding var isPresented: Bool
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    
    // Validation states
    @State private var isValidName: Bool = true
    @State private var isValidUsername: Bool = true
    @State private var isValidPhone: Bool = true
    @State private var isValidEmail: Bool = true
    
    // Error messages
    @State private var nameError: String = ""
    @State private var usernameError: String = ""
    @State private var phoneError: String = ""
    @State private var emailError: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Profili Düzenle")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primaryGreen)
                
                // Name Field
                VStack(alignment: .leading, spacing: 4) {
                    TextField("İsim Soyisim", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: name) {
                            validateName(name)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isValidName ? Color.clear : Color.red, lineWidth: 1)
                        )
                    
                    if !nameError.isEmpty {
                        Text(nameError)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Username Field
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Kullanıcı Adı", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .onChange(of: username) {
                            validateUsername(username)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isValidUsername ? Color.clear : Color.red, lineWidth: 1)
                        )
                    
                    if !usernameError.isEmpty {
                        Text(usernameError)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Email Field
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .onChange(of: email) {
                            validateEmail(email)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isValidEmail ? Color.clear : Color.red, lineWidth: 1)
                        )
                    
                    if !emailError.isEmpty {
                        Text(emailError)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                // Phone Field
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Telefon (+90XXXXXXXXXX)", text: $phone)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.phonePad)
                        .onChange(of: phone) {
                            validatePhone(phone)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isValidPhone ? Color.clear : Color.red, lineWidth: 1)
                        )
                    
                    if !phoneError.isEmpty {
                        Text(phoneError)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Spacer(minLength: 20)
                
                Button("Kaydet") {
                    if validateAllFields() {
                        let updatedUser = User(
                            id: userVM.user?.id ?? UUID(), 
                            name: name, 
                            username: username, 
                            phone: phone,
                            email: email
                        )
                        userVM.updateUser(updatedUser)
                        isPresented = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canSave())
                
                Button("İptal") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .onAppear {
            loadUserData()
        }
    }
    
    // MARK: - Validation Functions
    
    private func validateName(_ value: String) {
        if value.isEmpty {
            nameError = "İsim boş olamaz"
            isValidName = false
        } else if value.count < 2 {
            nameError = "İsim en az 2 karakter olmalı"
            isValidName = false
        } else if value.count > 50 {
            nameError = "İsim en fazla 50 karakter olabilir"
            isValidName = false
        } else {
            // İsim için basit regex: harf, boşluk, Türkçe karakterler
            let nameRegex = #"^[a-zA-ZğĞıİöÖüÜşŞçÇ\s]{2,50}$"#
            if !NSRegularExpression.matches(value, pattern: nameRegex) {
                nameError = "Geçersiz isim formatı"
                isValidName = false
            } else {
                nameError = ""
                isValidName = true
            }
        }
    }
    
    private func validateUsername(_ value: String) {
        if value.isEmpty {
            usernameError = "Kullanıcı adı boş olamaz"
            isValidUsername = false
        } else if !LocationHelper.validateUsername(value) {
            usernameError = "Kullanıcı adı 3-20 karakter, sadece harf, rakam ve _ içerebilir"
            isValidUsername = false
        } else {
            usernameError = ""
            isValidUsername = true
        }
    }
    
    private func validateEmail(_ value: String) {
        if value.isEmpty {
            emailError = "Email boş olamaz"
            isValidEmail = false
        } else if !LocationHelper.validateEmail(value) {
            emailError = "Geçersiz email formatı"
            isValidEmail = false
        } else {
            emailError = ""
            isValidEmail = true
        }
    }
    
    private func validatePhone(_ value: String) {
        if value.isEmpty {
            phoneError = "Telefon numarası boş olamaz"
            isValidPhone = false
        } else if !LocationHelper.validatePhoneNumber(value) {
            phoneError = "Geçersiz telefon formatı (+90XXXXXXXXXX veya 05XXXXXXXXX)"
            isValidPhone = false
        } else {
            phoneError = ""
            isValidPhone = true
        }
    }
    
    private func validateAllFields() -> Bool {
        validateName(name)
        validateUsername(username)
        validateEmail(email)
        validatePhone(phone)
        return isValidName && isValidUsername && isValidEmail && isValidPhone
    }
    
    private func canSave() -> Bool {
        return isValidName && isValidUsername && isValidEmail && isValidPhone && 
               !name.isEmpty && !username.isEmpty && !email.isEmpty && !phone.isEmpty
    }
    
    private func loadUserData() {
        name = userVM.user?.name ?? ""
        username = userVM.user?.username ?? ""
        phone = userVM.user?.phone ?? ""
        email = userVM.user?.email ?? ""
        
        // Initial validation
        validateName(name)
        validateUsername(username)
        validateEmail(email)
        validatePhone(phone)
    }
}

// MARK: - NSRegularExpression Extension

extension NSRegularExpression {
    static func matches(_ string: String, pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }
        let range = NSRange(location: 0, length: string.utf16.count)
        return regex.firstMatch(in: string, options: [], range: range) != nil
    }
} 