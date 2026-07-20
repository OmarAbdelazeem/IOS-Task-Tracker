import SwiftUI
import SwiftData
import Foundation

@main
struct FirstAppApp: App {
    private var isRunningUITests: Bool {
        ProcessInfo.processInfo.arguments.contains(
            "--ui-testing"
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(
            for: Goal.self,
            inMemory: isRunningUITests
        )
    }
}
