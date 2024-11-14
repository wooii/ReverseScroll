import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var eventTap: CFMachPort?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.prohibited)
        guard requestAccessibilityPermissions() else {
            NSApp.terminate(nil)
            return
        }
        setupEventTap()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
            self.eventTap = nil
        }
    }

    private func requestAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        if !accessEnabled {
            print("Accessibility permissions not granted.")
        }
        return accessEnabled
    }

    private func setupEventTap() {
        let eventMask = CGEventMask(1 << CGEventType.scrollWheel.rawValue)
        eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: AppDelegate.eventTapCallback,
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )
        guard let eventTap = eventTap else {
            print("Failed to create event tap.")
            NSApp.terminate(nil)
            return
        }
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    private func handleScrollEvent(event: CGEvent) -> Unmanaged<CGEvent>? {
        let isContinuous = event.getIntegerValueField(.scrollWheelEventIsContinuous) != 0
        guard !isContinuous else { return Unmanaged.passUnretained(event) }
        let deltaY = event.getDoubleValueField(.scrollWheelEventDeltaAxis1)
        let deltaX = event.getDoubleValueField(.scrollWheelEventDeltaAxis2)
        event.setDoubleValueField(.scrollWheelEventDeltaAxis1, value: -deltaY)
        event.setDoubleValueField(.scrollWheelEventDeltaAxis2, value: -deltaX)
        return Unmanaged.passUnretained(event)
    }

    private static let eventTapCallback: CGEventTapCallBack = { (_, type, event, refcon) -> Unmanaged<CGEvent>? in
        guard type == .scrollWheel, let refcon = refcon else {
            return Unmanaged.passUnretained(event)
        }
        let appDelegate = Unmanaged<AppDelegate>.fromOpaque(refcon).takeUnretainedValue()
        return appDelegate.handleScrollEvent(event: event)
    }
}
