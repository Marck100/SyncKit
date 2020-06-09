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
    let eventsToSave: [EKEvent]
    let eventsToEdit: [SKEvent]
    let eventsToDelete: [SKEvent]
}
