import SwiftUI

@main
struct ReverseScrollApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            Button("Quit Reverse Scroll") {
                NSApp.terminate(nil)
            }
        } label: {
            Image(systemName: "arrow.up.and.down.circle")
        }
    }
}
