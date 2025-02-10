import SwiftUI
import VisionKit

struct VisionScannerView: UIViewControllerRepresentable {
    @Binding var scannedImage: UIImage?
    @Binding var navigateToResult: Bool

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: VisionScannerView

        init(_ parent: VisionScannerView) {
            self.parent = parent
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            if scan.pageCount > 0 {
                // Take the first page only
                let image = scan.imageOfPage(at: 0)
                parent.scannedImage = image
                parent.navigateToResult = true
            }
            controller.dismiss(animated: true)
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Failed to scan document: \(error.localizedDescription)")
            controller.dismiss(animated: true)
        }
    }
}
