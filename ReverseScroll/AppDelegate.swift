import Cocoa
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    private var scrollHandler: ScrollHandler?
    private var permissionTimer: Timer?
    private let maxChecks = 10
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.prohibited)
        requestAccessibilityPermissions()
    }

    func applicationWillTerminate(_ notification: Notification) {
        permissionTimer?.invalidate()
        scrollHandler = nil
    }

    private func requestAccessibilityPermissions() {
        let options: CFDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let accessGranted = AXIsProcessTrustedWithOptions(options)
        if accessGranted {
            scrollHandler = ScrollHandler()
        } else {
            startPermissionTimer()
        }
    }

    private func startPermissionTimer() {
        var checkCount = 0
        permissionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            checkCount += 1
            if AXIsProcessTrusted() {
                timer.invalidate()
                addAppToLoginItems()
                scrollHandler = ScrollHandler()
            } else if checkCount >= self.maxChecks {
                timer.invalidate()
                print("Accessibility permissions not granted within \(maxChecks) seconds. Exiting app.")
                NSApp.terminate(nil)
            }
        }
    }

    private func addAppToLoginItems() {
        do {
            try SMAppService.mainApp.register()
            print("App successfully added to login items.")
        } catch {
            print("Failed to add app to login items: \(error.localizedDescription)")
        }
    }
}
