import Foundation

struct ReadingSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let wordsPerMinute: Double
    let pagesRead: Double
    let minutes: Double

    init(date: Date = Date(),
         wpm: Double,
         pages: Double,
         minutes: Double) {
        self.id = UUID()
        self.date = date
        self.wordsPerMinute = wpm
        self.pagesRead = pages
        self.minutes = minutes
    }
}
