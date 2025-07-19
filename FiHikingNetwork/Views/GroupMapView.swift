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
        // Kullanıcı türlerini belirle
        let isCurrentUser = member.id == viewModel.currentUserID
        
        // Leader ID karşılaştırması için hem String hem UUID formatlarını kontrol et
        let leaderIdString = viewModel.group?.leaderId?.uuidString ?? ""
        let leaderIdFromUUID = viewModel.group?.leaderId?.uuidString ?? ""
        let isGroupLeader = member.id == leaderIdString || member.id == leaderIdFromUUID
        
        // Debug logging
        debugMemberInfo(member: member, isCurrentUser: isCurrentUser, isGroupLeader: isGroupLeader)
        
        return Annotation(member.id, coordinate: member.coordinate) {
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
    
    /// Debug bilgilerini yazdırır
    private func debugMemberInfo(member: MemberLocation, isCurrentUser: Bool, isGroupLeader: Bool) {
        print("🗺️ Debug - Member ID: \(member.id)")
        print("🗺️ Debug - Current User ID: \(viewModel.currentUserID)")
        print("🗺️ Debug - Group Leader ID: \(viewModel.group?.leaderId?.uuidString ?? "nil")")
        print("🗺️ Debug - Is Current User: \(isCurrentUser)")
        print("🗺️ Debug - Is Group Leader: \(isGroupLeader)")
        print("🗺️ Debug - Group Name: \(viewModel.group?.name ?? "nil")")
        print("🗺️ Debug - ==================")
    }
    
    /// Mevcut kullanıcı görünümü
    private func currentUserView() -> some View {
        VStack {
            ZStack {
                // Ana hiking figürü
                Image(systemName: "figure.hiking")
                    .font(.title)
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.green)
                            .frame(width: 55, height: 55)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                
                // Küçük konum ikonu
                Image(systemName: "location.fill")
                    .font(.caption2)
                    .foregroundColor(.green)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 18, height: 18)
                    )
                    .offset(x: 20, y: -20)
            }
            
            Text("Sen")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.4), lineWidth: 1)
                )
        }
    }
    
    /// Grup lideri görünümü
    private func groupLeaderView() -> some View {
        VStack {
            ZStack {
                // Ana bayrak ikonu
                Image(systemName: "flag.fill")
                    .font(.title)
                    .foregroundColor(.red)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 55, height: 55)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                
                // Küçük hiking figürü üst kısımda
                Image(systemName: "figure.hiking")
                    .font(.caption)
                    .foregroundColor(.red)
                    .offset(y: -15)
            }
            
            Text("Lider")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    /// Normal üye görünümü
    private func memberView() -> some View {
        VStack {
            Image(systemName: "figure.hiking")
                .font(.title2)
                .foregroundColor(.blue)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 45, height: 45)
                        .overlay(
                            Circle()
                                .stroke(Color.blue.opacity(0.4), lineWidth: 2)
                        )
                )
            
            Text("Üye")
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
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
