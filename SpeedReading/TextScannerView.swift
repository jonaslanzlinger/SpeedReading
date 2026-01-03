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

            let images = (0..<scan.pageCount).compactMap {
                scan.imageOfPage(at: $0).cgImage
            }

            DispatchQueue.global(qos: .userInitiated).async {
                var allText: [String] = []

                for image in images {
                    let request = VNRecognizeTextRequest { request, _ in
                        guard let observations = request.results as? [VNRecognizedTextObservation] else {
                            return
                        }

                        let strings = observations.compactMap {
                            $0.topCandidates(1).first?.string
                        }

                        allText.append(contentsOf: strings)
                    }

                    request.recognitionLevel = .fast
                    request.usesLanguageCorrection = false

                    let handler = VNImageRequestHandler(cgImage: image)
                    try? handler.perform([request])
                }

                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.parent.scannedText = allText.joined(separator: " ")
                    self.parent.dismiss()
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
