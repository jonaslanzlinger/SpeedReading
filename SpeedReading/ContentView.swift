import SwiftUI

struct ContentView: View {

    // MARK: - State
    @State private var scannedText: String = ""
    @State private var showScanner = false

    @State private var timeMinutes: String = ""
    @State private var pagesRead: String = ""

    // MARK: - Derived values

    var wordsPerPage: Int {
        scannedText
            .split { !$0.isLetter }
            .count
    }

    var wordsPerMinute: Double? {
        guard
            let time = Double(timeMinutes),
            let pages = Double(pagesRead),
            time > 0,
            pages > 0,
            wordsPerPage > 0
        else { return nil }

        let totalWords = Double(wordsPerPage) * pages
        return totalWords / time
    }

    // MARK: - UI
    var body: some View {
        NavigationView {
            Form {

                // --- Typical Page (Scanner) ---
                Section(header: Text("Typical Page")) {
                    Button {
                        scannedText = ""
                        showScanner = true
                    } label: {
                        Label("Scan Book Page", systemImage: "camera")
                    }

                    if wordsPerPage > 0 {
                        Text("📄 Words on page: \(wordsPerPage)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // --- Reading Session ---
                Section(header: Text("Reading Session")) {
                    TextField("Time spent (minutes)", text: $timeMinutes)
                        .keyboardType(.decimalPad)

                    TextField("Pages read", text: $pagesRead)
                        .keyboardType(.decimalPad)
                }

                // --- Result ---
                Section(header: Text("Result")) {
                    if let wpm = wordsPerMinute {
                        Text("📖 \(wpm, specifier: "%.0f") words / minute")
                            .font(.headline)
                    } else {
                        Text("Scan a page and enter values")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Reading Speed")
        }
        .sheet(isPresented: $showScanner) {
            TextScannerView(scannedText: $scannedText)
        }
    }
}

#Preview {
    ContentView()
}
