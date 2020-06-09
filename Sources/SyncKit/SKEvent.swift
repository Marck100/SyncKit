//
//  SKEvent.swift
//  
//
//  Created by Marco Pilloni on 09/06/2020.
//

import Foundation
import EventKit


/// This protocol allows you to synchronize your app events with system events.
/// Your `Event` class must conform to this protocol.
public protocol SKEvent: class {
    /// Should contain key informations for easy understanding.
    var debugDescription: String { get set }
    /// It must be `EKEvent` identifier.
    var eventIdentifier: String { get set }
    /// It must be `EKEvent` lastModifiedDate.
    var lastModifiedDate: Date? { get set }
    /// Default is `true`. If this variable is set to false, the event will not be considered for sincronyzathion.
    var isSavedOnCalendar: Bool { get }
    /// Get shared store used by `SKCenter`.
    var store: EKEventStore { get }
    /// System event
    var localEvent: EKEvent { get }
    /// Detects if main event has changed
    /// - Parameter event: updated event to compare to the main one
    func changesFrom(_ event: EKEvent) -> Bool
    /// Loads `EKEvent`
    func toEKEvent() -> EKEvent
    /// Saves event to system calendar. You should call `save()` from `SKCenter` and update `eventIdentifier`.
    func save() throws
    /// Updates system's event. You should call `update(_ span: EKSpan)` from `SKCenter`.
    func update(_ span: EKSpan) throws
    /// Deletes system's event. You should call `delete(_ span: EKSpan)` from `SKCenter`.
    func delete(_ span: EKSpan) throws
}

// Default implementation
public extension SKEvent {
    var store: EKEventStore {
        return SKCenter.shared.store
    }
    var localEvent: EKEvent {
        return toEKEvent()
    }
    func changesFrom(_ event: EKEvent) -> Bool {
        guard let eventLast = event.lastModifiedDate, let last = self.lastModifiedDate else { return true }
        return eventLast > last
    }
    func save() throws {
        guard isSavedOnCalendar else { return }
        let event = localEvent
        try SKCenter.shared.saveEvent(event)
        self.eventIdentifier = event.eventIdentifier
        self.lastModifiedDate = event.lastModifiedDate
    }
    func update(_ span: EKSpan) throws {
        guard isSavedOnCalendar else { return }
        let event = localEvent
        try SKCenter.shared.updateEvent(event, span: span)
        self.lastModifiedDate = event.lastModifiedDate
    }
    func delete(_ span: EKSpan) throws {
        try SKCenter.shared.deleteEvent(localEvent, span: span)
    }
}
