import SwiftUI

struct ContentView: View {
    
    @ObservedObject var store: ReadingStore

    // MARK: - State
    @State private var scannedText: String = ""
    @State private var showScanner = false

    @State private var timeMinutes: String = ""
    @State private var pagesRead: String = ""
    
    @State private var showSaveConfirmation = false
    
    @FocusState private var focusedField: Field?

    enum Field {
        case time
        case pages
    }

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
                        .focused($focusedField, equals: .time)

                    TextField("Pages read", text: $pagesRead)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .pages)
                }

                // --- Result ---
                Section(header: Text("Result")) {
                    if let wpm = wordsPerMinute,
                       let time = Double(timeMinutes),
                       let pages = Double(pagesRead) {

                        Text("📖 \(wpm, specifier: "%.0f") words / minute")
                            .font(.headline)

                        Button("Save Session") {
                            let session = ReadingSession(
                                wpm: wpm,
                                pages: pages,
                                minutes: time
                            )
                            store.add(session)
                            showSaveConfirmation = true
                        }
                    } else {
                        Text("Scan a page and enter values")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Reading Speed")

            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
        .sheet(isPresented: $showScanner) {
            TextScannerView(scannedText: $scannedText)
        }
        .alert("Saved", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your reading session has been saved.")
        }
    }
}

#Preview {
    ContentView(store: ReadingStore())
}
