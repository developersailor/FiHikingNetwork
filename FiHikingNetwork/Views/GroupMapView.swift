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
                    Annotation(member.id, coordinate: member.coordinate) {
                        // Mevcut kullanıcıyı farklı bir renkle göster
                        let isCurrentUser = member.id == viewModel.currentUserID
                        Image(systemName: "figure.hiking")
                            .font(.title2)
                            .foregroundColor(isCurrentUser ? .blue : .black)
                            .background(
                                Circle()
                                    .fill(isCurrentUser ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                                    .frame(width: 40, height: 40)
                            )
                    }
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
