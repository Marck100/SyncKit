//
//  File.swift
//  
//
//  Created by Marco Pilloni on 09/06/2020.
//

import Foundation
import EventKit

//MARK: SKEvent
extension Array where Element == SKEvent {
    func contains(event: EKEvent) -> Bool {
        return self.contains(where: { event.eventIdentifier == $0.eventIdentifier })
    }
    func contains(event: SKEvent) -> Bool {
        return self.contains(where: { event.eventIdentifier == $0.eventIdentifier })
    }
}

//MARK: EKEvent
extension Array where Element == EKEvent {
    func contains(event: SKEvent) -> Bool {
        return self.contains(where: { event.eventIdentifier == $0.eventIdentifier })
    }
    func contains(event: EKEvent) -> Bool {
        return self.contains(where: { event.eventIdentifier == $0.eventIdentifier })
    }
    mutating func reduce() {
        var newArray: [EKEvent] = []
        self.forEach { (event) in
            if event.isDetached || newArray.contains(where: { $0.eventIdentifier == event.eventIdentifier && $0.isDetached == false }) == false {
                newArray.append(event)
            }
        }
        self = newArray
    }
}

//MARK: SKCalendar
extension Array where Element == SKCalendar {
    func contains(calendar: EKCalendar) -> Bool {
        return self.contains(where: { calendar.calendarIdentifier == $0.calendarIdentifier })
    }
    func contains(calendar: SKCalendar) -> Bool {
        return self.contains(where: { calendar.calendarIdentifier == $0.calendarIdentifier })
    }
}

//MARK: EKCalendar
extension Array where Element == EKCalendar {
    func contains(calendar: SKCalendar) -> Bool {
        return self.contains(where: { calendar.calendarIdentifier == $0.calendarIdentifier })
    }
    func contains(calendar: EKCalendar) -> Bool {
        return self.contains(where: { calendar.calendarIdentifier == $0.calendarIdentifier })
    }
   
}
