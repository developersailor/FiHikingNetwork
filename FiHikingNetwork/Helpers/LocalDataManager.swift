import Foundation
import SwiftData

class LocalDataManager {
    static let shared = LocalDataManager()
    
    // SwiftData context
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: User.self)
        } catch {
            fatalError("SwiftData ModelContainer başlatılamadı: \(error)")
        }
    }
    
    // Kullanıcıyı kaydet (varsa güncelle)
    @MainActor
    func saveUser(_ user: User) {
        let context = container.mainContext
        if let existing = loadUser() {
            context.delete(existing)
        }
        context.insert(user)
        try? context.save()
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    // Kullanıcıyı yükle (ilk kullanıcıyı döndür)
    @MainActor
    func loadUser() -> User? {
        let context = container.mainContext
        let descriptor = FetchDescriptor<User>()
        return try? context.fetch(descriptor).first
    }
    
    // Kullanıcıyı sil
    @MainActor
    func deleteUser() {
        let context = container.mainContext
        if let user = loadUser() {
            context.delete(user)
            try? context.save()
        }
    }
    
    // Demo kullanıcı ekle ve QR kodunu konsola yazdır
    @MainActor
    func addDemoUser() {
        let demoUser = User(id: UUID(), name: "Demo User", username: "demo_user", phone: "1234567890")
        saveUser(demoUser)
        if let qrCode = QRCodeHelper.generateQRCode(from: demoUser.id.uuidString) {
            print("Demo Kullanıcı QR Kodu: \(qrCode)")
        } else {
            print("QR kod oluşturulamadı.")
        }
    }
    
    func getUser() -> User? {
        if let savedUserData = UserDefaults.standard.data(forKey: "currentUser") {
            let decoder = JSONDecoder()
            if let loadedUser = try? decoder.decode(User.self, from: savedUserData) {
                return loadedUser
            }
        }
        return nil
    }
}