import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @ObservedObject var groupVM: GroupViewModel
    @Binding var isPresented: Bool
    @State private var isScanning = true
    @State private var scannedCode: String?
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                if let scannedCode = scannedCode {
                    VStack(spacing: 16) {
                        Text("QR Kod Okundu!")
                            .font(.title2)
                            .bold()
                        Text("Grup ID: \(scannedCode)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("Gruba Katıl") {
                            joinGroup(groupId: scannedCode)
                        }
                        .buttonStyle(.borderedProminent)
                        Button("Tekrar Tara") {
                            self.scannedCode = nil
                            isScanning = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else {
                    ZStack {
                        Rectangle()
                            .fill(Color.black)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        VStack {
                            Text("QR Kodu Tarayın")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                            QRCodeScannerRepresentable(isScanning: $isScanning) { code in
                                print("QR Scanner: QR kod okundu: \(code)")
                                self.scannedCode = code
                                self.isScanning = false
                            }
                            .frame(width: 250, height: 250)
                            .accessibilityLabel("QR kod tarama alanı")
                            Button("Test QR Kodu") {
                                // Test için örnek QR kod - Bu ID'yi gerçek bir gruptan alın
                                print("QR Scanner: Test QR kodu butonu tıklandı")
                                // GERÇEK GRUP ID'sini buraya yazın (örnek: scannedCode = "GERÇEK_GRUP_ID_BURAYA")
                                scannedCode = "test-group-id-123" // Bu satırı gerçek grup ID ile değiştirin
                                isScanning = false
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.white)
                            .padding()
                        }
                    }
                }
                Spacer()
            }
            .navigationTitle("QR Kod Tara")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        isPresented = false
                    }
                }
            }
            .alert("Bilgi", isPresented: $showAlert) {
                Button("Tamam") {
                    if alertMessage.contains("başarılı") {
                        isPresented = false
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func joinGroup(groupId: String) {
        print("QR Scanner: Gruba katılma işlemi başlatılıyor. Grup ID: \(groupId)")
        
        // Gerçek grup katılma işlemini başlat
        groupVM.joinGroup(groupId: groupId)
        
        // GroupViewModel'deki işlem sonucunu kontrol etmek için
        // RxSwift Observable'ını dinleyebiliriz, ancak şimdilik basit bir delay ile kontrol edelim
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let errorMessage = self.groupVM.errorMessage ?? ""
            if errorMessage.isEmpty {
                print("QR Scanner: Gruba katılma işlemi başarılı görünüyor")
                self.alertMessage = "Gruba başarıyla katıldınız!"
            } else {
                print("QR Scanner: Gruba katılma işlemi başarısız: \(errorMessage)")
                self.alertMessage = "Gruba katılım başarısız: \(errorMessage)"
            }
            self.showAlert = true
        }
    }
}

// MARK: - Kamera ile QR Kod Okuyucu
struct QRCodeScannerRepresentable: UIViewControllerRepresentable {
    @Binding var isScanning: Bool
    var onCodeScanned: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        if isScanning {
            uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }

    class Coordinator: NSObject, QRScannerViewControllerDelegate {
        let parent: QRCodeScannerRepresentable
        init(parent: QRCodeScannerRepresentable) {
            self.parent = parent
        }
        func didFind(code: String) {
            parent.onCodeScanned(code)
        }
    }
}

protocol QRScannerViewControllerDelegate: AnyObject {
    func didFind(code: String)
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: QRScannerViewControllerDelegate?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var isScanning = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }

    private func setupCamera() {
        let session = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            return
        }
        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
        self.captureSession = session
        if isScanning {
            session.startRunning()
        }
    }

    func startScanning() {
        isScanning = true
        captureSession?.startRunning()
    }

    func stopScanning() {
        isScanning = false
        captureSession?.stopRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard isScanning else { return }
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let stringValue = metadataObject.stringValue {
            stopScanning()
            delegate?.didFind(code: stringValue)
        }
    }
} 