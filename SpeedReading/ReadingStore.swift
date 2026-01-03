import Foundation
import SwiftUI
import Combine

final class ReadingStore: ObservableObject {
    @Published var sessions: [ReadingSession] = [] {
        didSet { save() }
    }

    private let key = "reading_sessions"

    init() {
        load()
    }

    func add(_ session: ReadingSession) {
        sessions.append(session)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode([ReadingSession].self, from: data)
        else { return }

        sessions = decoded
    }
    
    func delete(_ session: ReadingSession) {
        sessions.removeAll { $0.id == session.id }
    }
}
