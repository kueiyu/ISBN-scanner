//
//  ContentView.swift
//  ISBN-scanner
//
//  Created by 藍藍開發 on 2023/2/13.
//

import SwiftUI
import CoreData
import AVFoundation

struct ContentView: View {

    @State private var showingAlert = false
    @State private var scannedISBN = ""
    @State private var isScannerActive = false
    
    var body: some View {
        VStack {
            if isScannerActive {
                ScannerView(scannedISBN: $scannedISBN, isScannerActive: $isScannerActive)
            } else {
                Button("Scan ISBN") {
                    self.isScannerActive = true
                }
                .padding()
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Scanned ISBN"), message: Text(scannedISBN), dismissButton: .default(Text("OK")))
        }
    }
}

struct ScannerView: UIViewRepresentable {
    
    @Binding var scannedISBN: String
    @Binding var isScannerActive: Bool
    
    typealias UIViewType = UIView
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        DispatchQueue.main.async {
            let scanner = ScannerViewController()
            scanner.delegate = context.coordinator
            view.addSubview(scanner.view)
            context.coordinator.scanner = scanner
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(scannedISBN: $scannedISBN, isScannerActive: $isScannerActive)
    }
    
    class Coordinator: NSObject, ScannerViewControllerDelegate {
        
        @Binding var scannedISBN: String
        @Binding var isScannerActive: Bool
        
        var scanner: ScannerViewController?
        
        init(scannedISBN: Binding<String>, isScannerActive: Binding<Bool>) {
            _scannedISBN = scannedISBN
            _isScannerActive = isScannerActive
        }
        
        func didScanBarcodeWithResult(result: String) {
            scannedISBN = result
            isScannerActive = false
            scanner?.dismiss(animated: true, completion: nil)
        }
    }
}

protocol ScannerViewControllerDelegate: AnyObject {
    func didScanBarcodeWithResult(result: String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    weak var delegate: ScannerViewControllerDelegate?
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .ean8] // This line specifies the types of barcodes to scan
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func failed(){
        NSLog("captureSession could not add input");
    }
}
