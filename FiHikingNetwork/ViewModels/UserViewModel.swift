import Foundation
import SwiftData

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?
    
    init() {
        Task {
            await loadUserFromCache()
        }
    }
    
    func updateUser(_ newUser: User) {
        self.user = newUser
        LocalDataManager.shared.saveUser(newUser)
    }
    
    func loadUserFromCache() async {
        if let cachedUser = await LocalDataManager.shared.loadUser() {
            self.user = cachedUser
        }
    }
    
    func deleteUser() {
        self.user = nil
        Task {
            await LocalDataManager.shared.deleteUser()
        }
    }
} 