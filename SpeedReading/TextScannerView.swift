import SwiftUI
import Vision
import VisionKit

struct TextScannerView: UIViewControllerRepresentable {

    @Binding var scannedText: String
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let cameraVC = VNDocumentCameraViewController()
        cameraVC.delegate = context.coordinator
        return cameraVC
    }

    func updateUIViewController(
        _ uiViewController: VNDocumentCameraViewController,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {

        let parent: TextScannerView

        init(_ parent: TextScannerView) {
            self.parent = parent
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {

            parent.scannedText = ""

            let textRecognitionRequest = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    return
                }

                let recognizedStrings = observations.compactMap {
                    $0.topCandidates(1).first?.string
                }

                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.parent.scannedText = recognizedStrings.joined(separator: " ")
                    self.parent.dismiss()
                }
            }

            textRecognitionRequest.recognitionLevel = .accurate
            textRecognitionRequest.usesLanguageCorrection = true

            let images = (0..<scan.pageCount).compactMap {
                scan.imageOfPage(at: $0).cgImage
            }

            DispatchQueue.global(qos: .userInitiated).async {
                for image in images {
                    let handler = VNImageRequestHandler(cgImage: image)
                    try? handler.perform([textRecognitionRequest])
                }
            }
        }

        func documentCameraViewControllerDidCancel(
            _ controller: VNDocumentCameraViewController
        ) {
            parent.dismiss()
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {
            print("Document scan failed:", error)
            parent.dismiss()
        }
    }
}
