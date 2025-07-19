import Foundation
import SwiftData

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?
    
    init() {
        loadUserFromCache()
    }
    
    func updateUser(_ newUser: User) {
        self.user = newUser
        LocalDataManager.shared.saveUser(newUser)
    }
    
    func loadUserFromCache() {
        if let cachedUser = LocalDataManager.shared.loadUser() {
            self.user = cachedUser
            print("✅ UserViewModel: Cache'den kullanıcı yüklendi: \(cachedUser.name)")
        } else {
            print("❌ UserViewModel: Cache'de kullanıcı bulunamadı")
        }
    }
    
    func deleteUser() {
        self.user = nil
        LocalDataManager.shared.deleteUser()
    }
} 