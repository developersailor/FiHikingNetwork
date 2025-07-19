import SwiftUI

struct MainView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var mapVM: MapViewModel
    @State private var showCreateGroup = false
    @State private var showQRScanner = false

    var body: some View {
        // AppViewModel'den currentUserID'yi alabildiğimizden emin olalım
        if let currentUserID = appViewModel.currentUserID {
            ContentView(currentUserID: currentUserID, userVM: userVM, mapVM: mapVM, showCreateGroup: $showCreateGroup, showQRScanner: $showQRScanner)
        } else {
            ProgressView("Kullanıcı bilgisi yükleniyor...")
        }
    }
}

struct ContentView: View {
    let currentUserID: String
    let userVM: UserViewModel
    let mapVM: MapViewModel
    @Binding var showCreateGroup: Bool
    @Binding var showQRScanner: Bool
    
    @StateObject private var groupVM: GroupViewModel
    
    init(currentUserID: String, userVM: UserViewModel, mapVM: MapViewModel, showCreateGroup: Binding<Bool>, showQRScanner: Binding<Bool>) {
        self.currentUserID = currentUserID
        self.userVM = userVM
        self.mapVM = mapVM
        self._showCreateGroup = showCreateGroup
        self._showQRScanner = showQRScanner
        // GroupViewModel'i currentUserID ile başlatıyoruz
        self._groupVM = StateObject(wrappedValue: GroupViewModel(currentUserID: currentUserID))
    }

    var body: some View {
        NavigationView {
            if userVM.user == nil {
                OnboardingView(userVM: userVM)
            } else {
                VStack(spacing: 24) {
                    ProfileView(userVM: userVM, groupVM: groupVM)
                    if let group = groupVM.group {
                        VStack(spacing: 8) {
                            Text("Aktif Grup: \(group.name)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            NavigationLink("Haritada Grubu Gör", destination: GroupMapView(group: group, currentUserID: currentUserID))
                                .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        VStack(spacing: 16) {
                            Text("Henüz bir gruba katılmadınız")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 16) {
                                Button("Grup Oluştur") {
                                    showCreateGroup = true
                                }
                                .buttonStyle(.borderedProminent)
                                
                                Button("QR ile Katıl") {
                                    showQRScanner = true
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Spacer()
                }
                .padding()
                .navigationTitle("FiHiking")
                .navigationBarTitleDisplayMode(.large)
                .sheet(isPresented: $showCreateGroup) {
                    CreateGroupView(groupVM: groupVM, isPresented: $showCreateGroup)
                }
                .sheet(isPresented: $showQRScanner) {
                    QRScannerView(groupVM: groupVM, isPresented: $showQRScanner)
                }
            }
        }
        .background(Color(UIColor(named: "NaturalBeige") ?? UIColor.white))
    }
}

#Preview {
    ContentView(
        currentUserID: "preview_user_123",
        userVM: UserViewModel(),
        mapVM: MapViewModel(),
        showCreateGroup: .constant(false),
        showQRScanner: .constant(false)
    )
}