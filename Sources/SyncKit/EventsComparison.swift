//
//  EventsComparison.swift
//  
//
//  Created by Marco Pilloni on 09/06/2020.
//

import Foundation
import EventKit


/// Result of comparison between events stored in your database and system events.
public struct EventsComparison {
    public let eventsToSave: [EKEvent]
    public let eventsToEdit: [SKEvent]
    public let eventsToDelete: [SKEvent]
}
