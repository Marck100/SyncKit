//
//  SKCalendar.swift
//  
//
//  Created by Marco Pilloni on 09/06/2020.
//

import Foundation
import EventKit


/// This protocol allows you to synchronize your app calendars with system calendars.
/// Your `Calendar` class must conform to this protocol.
public protocol SKCalendar: class {
    /// Should contain key informations for easy understanding.
    var debugDescription: String { get set }
    /// It must be `EKCalendar` identifier.
    var calendarIdentifier: String { get set }
    /// Default is `true`. If this variable is set to false, the calendar will not be considered for sincronyzathion.
    var isSavedOnCalendar: Bool { get }
    /// Get shared store used by `SKCenter`.
    var store: EKEventStore { get }
    /// System calendar
    var localCalendar: EKCalendar { get }
    /// Detects if main calendar has changed
    /// - Parameter calendar: updated calendar to compare to the main one
    func changesFrom(_ calendar: EKCalendar) -> Bool
    /// Loads `EKCalendar`
    func toEKCalendar() -> EKCalendar
    /// Saves calendar to system calendar. You should call `save()` from `SKCenter` and update `calendarIdentifier`.
    func save() throws
    /// Updates system's calendar. You should call `update()` from `SKCenter`.
    func update() throws
    /// Deletes system's calendar. You should call `delete()` from `SKCenter`.
    func delete() throws
}

// Default implementation
public extension SKCalendar {
    var store: EKEventStore {
        return SKCenter.shared.store
    }
    var localCalendar: EKCalendar {
        return toEKCalendar()
    }
    func save() throws {
        guard isSavedOnCalendar else { return }
        let calendar = localCalendar
        try SKCenter.shared.saveCalendar(calendar)
        self.calendarIdentifier = calendar.calendarIdentifier
    }
    func update() throws {
        guard isSavedOnCalendar else { return }
        try SKCenter.shared.updateCalendar(localCalendar)
    }
    func delete() throws {
        try SKCenter.shared.deleteCalendar(localCalendar)
    }
}
