import SwiftUI

struct SplashView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var mapVM: MapViewModel
    @State private var isLoading = true
    @State private var shouldShowOnboarding = false

    var body: some View {
        if isLoading {
            VStack {
                Spacer()
                ProgressView("Yükleniyor...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                Spacer()
            }
            .onAppear {
                Task {
                    await userVM.loadUserFromCache()
                    shouldShowOnboarding = userVM.user == nil
                    isLoading = false
                }
            }
        } else {
            if shouldShowOnboarding {
                OnboardingView(userVM: userVM)
                    .onChange(of: userVM.user) { _, newUser in
                        if newUser != nil {
                            shouldShowOnboarding = false
                        }
                    }
            } else {
                MainView()
                    .environmentObject(mapVM)
                    .environmentObject(userVM)
            }
        }
    }
} 