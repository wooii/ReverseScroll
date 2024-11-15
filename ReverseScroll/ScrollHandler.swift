// ScrollHandler.swift
import Cocoa

class ScrollHandler {
    private var eventTap: CFMachPort?

    init() {
        setupEventTap()
    }

    deinit {
        disableEventTap()
    }

    private func setupEventTap() {
        let eventMask = CGEventMask(1 << CGEventType.scrollWheel.rawValue)
        eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: ScrollHandler.eventTapCallback,
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )
        guard let eventTap = eventTap else {
            print("Failed to create event tap.")
            return
        }
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    private func disableEventTap() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
            self.eventTap = nil
        }
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
        let ScrollHandler = Unmanaged<ScrollHandler>.fromOpaque(refcon).takeUnretainedValue()
        return ScrollHandler.handleScrollEvent(event: event)
    }
}
