import SwiftUI

struct CalendarView: View {
    @ObservedObject var store: ReadingStore
    @State private var selectedDate = Date()

    var sessionsForDay: [ReadingSession] {
        store.sessions.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)

                List {
                    ForEach(sessionsForDay) { session in
                        VStack(alignment: .leading) {
                            Text("📖 \(session.wordsPerMinute, specifier: "%.0f") WPM")
                                .font(.headline)

                            Text("\(session.pagesRead, specifier: "%.1f") pages · \(session.minutes, specifier: "%.0f") min")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.map { sessionsForDay[$0] }.forEach {
                            store.delete($0)
                        }
                    }
                }

            }
            .navigationTitle("Reading Calendar")
            .toolbar {
                EditButton()
            }
        }
    }
}
