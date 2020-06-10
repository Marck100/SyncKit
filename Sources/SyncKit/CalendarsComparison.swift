//
//  CalendarsComparison.swift
//  
//
//  Created by Marco Pilloni on 09/06/2020.
//

import Foundation
import EventKit


/// Result of comparison between calendars stored in your database and system calendars.
public struct CalendarsComparison {
    public let calendarsToSave: [EKCalendar]
    public let calendarsToEdit: [EKCalendar]
    public let calendarsToDelete: [SKCalendar]
}
