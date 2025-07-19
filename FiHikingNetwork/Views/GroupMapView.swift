import SwiftUI
import MapKit

struct GroupMapView: View {
    // ViewModel'i @StateObject olarak oluşturuyoruz, çünkü bu View'ın sahibi o.
    @StateObject private var viewModel: GroupViewModel

    // Haritanın kamera pozisyonunu yönetmek için State
    @State private var mapPosition: MapCameraPosition = .automatic

    // Initializer, bir HikingGroup nesnesi ve kullanıcı kimliği alarak ViewModel'i başlatır.
    init(group: HikingGroup, currentUserID: String) {
        _viewModel = StateObject(wrappedValue: GroupViewModel(group: group, currentUserID: currentUserID))
    }

    var body: some View {
        ZStack {
            // Harita görünümü
            Map(position: $mapPosition) {
                // ViewModel'den gelen üye konumlarını haritada göster
                ForEach(viewModel.memberLocations) { member in
                    memberAnnotation(for: member)
                }
            }
            .mapStyle(.standard(elevation: .realistic)) // Daha gerçekçi bir harita stili
            .onAppear(perform: setupView) // View göründüğünde kurulumu yap
            .onDisappear(perform: viewModel.stopLocationTracking) // View kaybolduğunda takibi durdur
            
            // Hata mesajı göstermek için bir overlay
            if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(10)
                    Spacer()
                }
                .padding()
                .transition(.move(edge: .top))
            }
        }
        .navigationTitle(viewModel.group?.name ?? "Grup Haritası")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// View ilk yüklendiğinde yapılacak işlemler.
    private func setupView() {
        viewModel.startLocationTracking()
    }
    
    /// Üye için harita annotation'ı oluşturur
    private func memberAnnotation(for member: MemberLocation) -> some MapContent {
        Annotation(member.id, coordinate: member.coordinate) {
            // Kullanıcı türlerini belirle
            let isCurrentUser = member.id == viewModel.currentUserID
            let isGroupLeader = member.id == (viewModel.group?.leaderId?.uuidString ?? "")
            
            VStack {
                // Üye türüne göre farklı simge ve renkler
                if isCurrentUser {
                    currentUserView()
                } else if isGroupLeader {
                    groupLeaderView()
                } else {
                    memberView()
                }
            }
        }
    }
    
    /// Mevcut kullanıcı görünümü
    private func currentUserView() -> some View {
        VStack {
            Image(systemName: "figure.hiking")
                .font(.title2)
                .foregroundColor(.blue)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 50, height: 50)
                )
            Text("Sen")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(12)
        }
    }
    
    /// Grup lideri görünümü
    private func groupLeaderView() -> some View {
        VStack {
            Image(systemName: "crown.fill")
                .font(.title2)
                .foregroundColor(.orange)
                .background(
                    Circle()
                        .fill(Color.orange.opacity(0.3))
                        .frame(width: 50, height: 50)
                )
            Text("Lider")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(12)
        }
    }
    
    /// Normal üye görünümü
    private func memberView() -> some View {
        VStack {
            Image(systemName: "figure.hiking")
                .font(.title2)
                .foregroundColor(.gray)
                .background(
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                )
            Text("Üye")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
    }
}

// SwiftUI Preview için örnek bir yapı
struct GroupMapView_Previews: PreviewProvider {
    static var previews: some View {
        // Örnek bir grup oluşturarak GroupMapView'i önizle
        let sampleGroup = HikingGroup(
            id: UUID(), 
            name: "Doğa Yürüyüşü Ekibi", 
            memberIDs: [UUID(), UUID()]
        )
        // Önizleme için sahte bir kullanıcı kimliği sağlıyoruz.
        let sampleUserID = "preview_user_123"
        
        NavigationView {
            GroupMapView(group: sampleGroup, currentUserID: sampleUserID)
        }
    }
}
