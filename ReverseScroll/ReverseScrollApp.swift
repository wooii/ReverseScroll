// ReverseScrollApp.swift
import AppKit
import SwiftUI

@main
struct ReverseScrollApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            Text("ReverseScroll")
                .font(.headline)
            Divider()
            Button("About") {
                if let url = URL(string: "https://github.com/wooii/ReverseScroll") {
                    NSWorkspace.shared.open(url)
                }
            }
            Button("Quit") {
                NSApp.terminate(nil)
            }
        } label: {
            Image(systemName: "arrow.up.and.down.circle")
        }
    }
}
