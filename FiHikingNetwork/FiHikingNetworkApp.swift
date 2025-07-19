//
//  FiHikingApp.swift
//  FiHiking
//
//  Created by Mehmet Fışkındal on 14.07.2025.
//

import SwiftUI
import CoreLocation
import FirebaseCore

@main
struct FiHikingNetworkApp: App {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var userViewModel = UserViewModel()
    
    init() {
        // Uygulama başlangıç ayarları
        setupAppearance()
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            // AppViewModel'in durumuna göre hangi görünümün gösterileceğine karar ver.
            switch appViewModel.appState {
            case .loading:
                // Yüklenirken bir bekleme ekranı gösterilebilir.
                ProgressView("Oturum açılıyor...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
            case .signedIn:
                // Kullanıcı giriş yaptıysa, MainView'i göster ve tüm ViewModel'leri çevreye ekle.
                MainView()
                    .environmentObject(appViewModel)
                    .environmentObject(mapViewModel)
                    .environmentObject(userViewModel)
            case .signedOut:
                // Kullanıcı çıkış yaptıysa veya oturum açılamadıysa onboarding ekranı göster.
                OnboardingView(userVM: userViewModel)
                    .environmentObject(appViewModel)
            case .error(let message):
                // Bir hata oluşursa, kullanıcıya bilgi ver.
                VStack(spacing: 16) {
                    Text("Bir Hata Oluştu")
                        .font(.title)
                        .foregroundColor(.red)
                    Text(message)
                        .padding()
                        .multilineTextAlignment(.center)
                    Button("Tekrar Dene") {
                        // AppViewModel'i yeniden başlat
                        Task {
                            await MainActor.run {
                                // Basit bir yeniden başlatma mantığı
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
    }
    
    private func setupAppearance() {
        // Navigation bar görünümü
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
