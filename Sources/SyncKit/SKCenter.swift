//
//  SKCenter.swift
//  
//
//  Created by Marco Pilloni on 09/06/2020.
//

import Foundation
import EventKit


// Manages system events and calendars.
final public class SKCenter {
    static public let shared = SKCenter()
    
    public enum SKError: Error {
        case authorization(_ authorizationStatus: EKAuthorizationStatus)
    }
    /// Store used to add, save, edit and retrieve datas from system
    let store = EKEventStore()
    /// Used to load events with specific interval
    public typealias SKInterval = (startDate: Date, endDate: Date)
    
    private init() {
    }
    /// You must request access to system resources to continue.
    /// Remeber to update privacy keys in your `info.plist` file
    public func requestAccess(_ requestHandler: (@escaping(Bool, Error?) -> Void) = {_,_ in }) {
        store.requestAccess(to: .event, completion: requestHandler)
    }
    
    //MARK:- EKCalendar
    func saveCalendar(_ calendar: EKCalendar) throws {
        try store.saveCalendar(calendar, commit: true)
    }
    func updateCalendar(_ calendar: EKCalendar) throws {
        try store.saveCalendar(calendar, commit: true)
    }
    func deleteCalendar(_ calendar: EKCalendar) throws {
        try store.removeCalendar(calendar, commit: true)
    }
    
    /// Load calendars from system
    /// - Parameter identifiers: you can specify calendars that you want to load.
    func retrieveCalendars(_ identifiers: [String]? = nil) throws -> [EKCalendar] {
        let authStatus = EKEventStore.authorizationStatus(for: .event)
        guard authStatus == .authorized else { throw SKError.authorization(authStatus) }
        
        let calendars = store.calendars(for: .event)
        if let identifiers = identifiers, identifiers.isEmpty == false {
            return calendars.filter { identifiers.contains( $0.calendarIdentifier ) }
        } else {
            return calendars
        }
    
    }
    
    /// Compare system calendars with calendars stored in your database.
    /// - Parameters:
    ///   - calendars: system calendars
    ///   - storedCalendars: calendars stored in your database.
    func compareCalendars(calendars: [EKCalendar], storedCalendars: [SKCalendar]) -> CalendarsComparison {
        let storedCalendars = storedCalendars.filter { $0.isSavedOnCalendar }
        // To delete
        let calendarsToDelete: [SKCalendar] = {
            let calendars = storedCalendars.filter { (storedCalendar) -> Bool in
                return calendars.contains(calendar: storedCalendar) == false
            }
            return calendars
        }()
        let storedCalendarsToCompare: [SKCalendar] = {
            let calendars = storedCalendars.filter { (storedCalendar) -> Bool in
                return calendarsToDelete.contains(calendar: storedCalendar) == false
            }
            return calendars
        }()
        // To save
        let calendarsToSave: [EKCalendar] = {
            let calendars: [EKCalendar] = calendars.filter { (calendar) -> Bool in
                return storedCalendarsToCompare.contains(calendar: calendar) == false
            }
            return calendars
        }()
        let calendarsToCompare: [EKCalendar] = {
            let calendars: [EKCalendar] = calendars.filter { (calendar) -> Bool in
                return calendarsToSave.contains(calendar: calendar) == false
            }
            return calendars
        }()
        // To edit
        let calendarsToEdit: [SKCalendar] = {
            let calendars = storedCalendarsToCompare.filter { (storedCalendar) -> Bool in
                return calendarsToCompare.contains(where: { storedCalendar.calendarIdentifier == $0.calendarIdentifier && storedCalendar.changesFrom($0) })
            }
            return calendars
        }()
        
        return CalendarsComparison(calendarsToSave: calendarsToSave, calendarsToEdit: calendarsToEdit, calendarsToDelete: calendarsToDelete)
    }
    
    /// Compare calendars stored in your database with system calendars
    /// - Parameters:
    ///   - identifiers: you can load specific calendars using their identifiers
    ///   - storedCalendars: calendars stored in your database
    public func compareCalendars(withIdentifiers identifiers: [String], storedCalendars: [SKCalendar]) throws -> CalendarsComparison {
        let calendars = try retrieveCalendars(identifiers)
        return compareCalendars(calendars: calendars, storedCalendars: storedCalendars)
    }
    
    //MARK:- EKEvent
    func saveEvent(_ event: EKEvent) throws {
        try store.save(event, span: .thisEvent, commit: true)
    }
    
    func updateEvent(_ event: EKEvent, span: EKSpan) throws {
        try store.save(event, span: span, commit: true)
    }
    
    func deleteEvent(_ event: EKEvent, span: EKSpan) throws {
        try store.remove(event, span: span, commit: true)
    }
    
    /// Load events from system with specific interval and calendars
    /// - Parameters:
    ///   - startDate: interval start date
    ///   - endDate: interval end date
    ///   - calendars: calendars associated to events
    fileprivate func retrieveEvents(withInterval interval: SKInterval, calendars: [EKCalendar]? = nil) throws -> [EKEvent] {
        let authStatus = EKEventStore.authorizationStatus(for: .event)
        guard authStatus == .authorized else { throw SKError.authorization(authStatus) }
        
        let predicate = store.predicateForEvents(withStart: interval.startDate, end: interval.endDate, calendars: calendars)
        var events = store.events(matching: predicate)
        events.reduce()
        return events
    }
    
    /// Compare system events with events stored in your database
    /// - Parameters:
    ///   - events: system events
    ///   - storedEvents: events stored in your database
    fileprivate func compareEvents(events: [EKEvent], storedEvents: [SKEvent]) -> EventsComparison {
        let storedEvents = storedEvents.filter { $0.isSavedOnCalendar }
        // To delete
        let eventsToDelete: [SKEvent] = {
            let events = storedEvents.filter { (storedEvent) -> Bool in
                return events.contains(event: storedEvent) == false
            }
            return events
        }()
        let storedEventsToCompare: [SKEvent] = {
            let events = storedEvents.filter { (storedEvent) -> Bool in
                return eventsToDelete.contains(event: storedEvent) == false
            }
            return events
        }()
        // To save
        let eventsToSave: [EKEvent] = {
            let events: [EKEvent] = events.filter { (event) -> Bool in
                return storedEventsToCompare.contains(event: event) == false
            }
            return events
        }()
        let eventsToCompare: [EKEvent] = {
            let events: [EKEvent] = events.filter { (event) -> Bool in
                return eventsToSave.contains(event: event) == false
            }
            return events
        }()
        // To edit
        let eventsToEdit: [SKEvent] = {
            let events = storedEventsToCompare.filter { (storedEvent) -> Bool in
                return eventsToCompare.contains(where: { storedEvent.eventIdentifier == $0.eventIdentifier && storedEvent.changesFrom($0) })
            }
            return events
        }()
        
        return EventsComparison(eventsToSave: eventsToSave, eventsToEdit: eventsToEdit, eventsToDelete: eventsToDelete)
    }
    
    /// Compare events stored in yout database with events loaded using specific interval and calendars
    /// - Parameters:
    ///   - interval: all events must be included in the interval
    ///   - calendars: you can load events with specific calendars
    ///   - storedEvents: events saved in your database
    public func compareEvents(withInterval interval: SKInterval, calendars: [EKCalendar]? = nil, storedEvents: [SKEvent]) throws -> EventsComparison {
        let events = try retrieveEvents(withInterval: interval, calendars: calendars)
        return compareEvents(events: events, storedEvents: storedEvents)
    }
    
}
