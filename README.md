# SyncKit

SyncKit allows you to synchronize system events and calendars with your database.

### How to implement this package

1. Conform your Event and Calendar class to `SKEvent` and `SKCalendar`

```swift
class Event: SKEvent {
   
   var title: String
   var eventIdentifier: String
   
   var lastModifiedDate: Date?
   ...
   
    func toEKEvent() -> EKEvent {
        if let event = store.event(withIdentifier: eventIdentifier) {
            event.title = title
            ...
            return event
        } else {
            let event = EKEvent(eventStore: store)
            ...
            return event
        }
    }
    
}
```

2. Request access to event( You must implement Privacy keys in your `info.plist` )
3. Compare events and calendars stored in your app with system ones.

```swift
let comparison = SKCenter.shared.compareCalendars(calendars: systemCalendars, storedCalendars: storedCalendars)
```

4. Update your app
```swift
db.save(comparison.calendarsToSave)
db.update(comparison.calendarsToUpdate)
db.remove(comparison.calendarsToDelete)
```


