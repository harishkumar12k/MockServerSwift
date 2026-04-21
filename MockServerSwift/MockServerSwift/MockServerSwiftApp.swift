//
//  MockServerSwiftApp.swift
//  MockServerSwift
//
//  Created by Harish Kumar on 21/04/26.
//

import SwiftUI
import SwiftData

@main
struct MockServerSwiftApp: App {
    @StateObject private var serverManager = MockServerManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Item.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(serverManager) // Inject manager so all windows can see it
        }
        .modelContainer(sharedModelContainer)
    }
}
