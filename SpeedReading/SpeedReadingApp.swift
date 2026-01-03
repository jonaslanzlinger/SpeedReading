//
//  SpeedReadingApp.swift
//  SpeedReading
//
//  Created by Jonas Länzlinger on 02.01.2026.
//

import SwiftUI

@main
struct SpeedReadingApp: App {
    @StateObject private var store = ReadingStore()

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView(store: store)
                    .tabItem {
                        Label("Session", systemImage: "book")
                    }

                CalendarView(store: store)
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
            }
        }
    }
}
