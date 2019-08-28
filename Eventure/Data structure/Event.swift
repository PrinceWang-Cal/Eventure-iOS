//
//  Event.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class Event {
    static var current: Event?
    static var drafts = [Event]()
    
    private static var cachedEvents = [String: [[String: Any]]]()

    let readableFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy @ h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    let uuid: String
    var title: String
    var location: String
    var startTime: Date?
    var endTime: Date?
    var eventDescription: String
    var eventVisual: UIImage?
    var hostID: String
    var hostTitle: String
    var currentUserGoingStatus: Going = .neutral
    var tags = Set<String>()
    // # of interested, # of going
    // API: array of user id
    
    var published: Bool
    var active: Bool
    
    // MARK: Computed properties
    
    /// A description of the start time of the event.
    var timeDescription: String {
        if startTime != nil {
            return readableFormatter.string(from: startTime!)
        } else {
            return "Unspecified"
        }
    }
    
    /// A description of the duration of the event.
    var duration: String {
        let dc = DateComponentsFormatter()
        dc.allowedUnits = [.month, .weekOfMonth, .day, .hour, .minute]
        dc.zeroFormattingBehavior = .dropLeading
        dc.maximumUnitCount = 2
        dc.unitsStyle = .full
        
        if startTime != nil && endTime != nil {
            return dc.string(from: endTime!.timeIntervalSince(startTime!))!
        } else {
            return "TBD"
        }
    }
    
    /// Returns an empty `Event` object.
    static var empty: Event {
        return Event(uuid: UUID().uuidString.lowercased(),
                     title: "",
                     description: "",
                     startTime: "",
                     endTime: "",
                     location: "",
                     tags: Set<String>(),
                     hostID: Organization.current?.id ?? "<org id>",
                     hostTitle: Organization.current?.title ?? "<Title>")
    }
    
    init(uuid: String, title: String, description: String, startTime: String, endTime: String, location: String, tags: Set<String>, hostID: String, hostTitle: String) {
        self.uuid = uuid
        self.title = title
        self.startTime = DATE_FORMATTER.date(from: startTime)
        self.endTime = DATE_FORMATTER.date(from: endTime)
        self.location = location
        self.tags = tags
        self.hostID = hostID
        self.hostTitle = hostTitle
        self.active = true
        self.published = false
        self.eventDescription = description
    }
    
    init(eventInfo: JSON) {
        let dictionary = eventInfo.dictionary!
        
        uuid = dictionary["uuid"]?.string ?? ""
        title = dictionary["Title"]?.string ?? ""
        location = dictionary["Location"]?.string ?? ""
        if let startTimeString = dictionary["Start time"]?.string {
            self.startTime = DATE_FORMATTER.date(from: startTimeString)
        }
        if let endTimeString = dictionary["End time"]?.string {
            self.endTime = DATE_FORMATTER.date(from: endTimeString)
        }
        eventDescription = dictionary["Description"]?.string ?? ""
        //eventDescription = dictionary["Description"]?.string ?? ""
        if let hostInfo = dictionary["Organization"] {
            let org = Organization(orgInfo: hostInfo)
            hostTitle = org.title
            hostID = org.id
        } else {
            hostTitle = "<Title>"
            hostID = "<org id>"
        }
        
        published = (dictionary["Published"]?.int ?? 0) == 1
        
        /*let attendees_raw = { () -> [String] in
         var attendees_arr = [String]()
         for a in attendees {
         attendees_arr.append(a.email)
         }
         return attendees_arr
         }()
         
         if let attendees_raw = dictionary["Attendees"]?.string {
         let attendees_Email = (JSON(parseJSON: attendees_raw).arrayObject as? [String]) ?? [String]()
         }*/
        
        if let tags_raw = dictionary["Tags"]?.string {
            let tagsArray = (JSON(parseJSON: tags_raw).arrayObject as? [String]) ?? [String]()
            tags = Set(tagsArray)
        } else {
            tags = []
        }
        
        if let going_raw = dictionary["Going"]?.int {
            currentUserGoingStatus = Going(rawValue: going_raw) ?? .neutral
        }
        
        active = (dictionary["Active"]?.int ?? 1) == 1
    }
    
    static func readFromFile(path: String) -> [String: [Event]] {
        
        var events = [String: [Event]]()
        
        guard let fileData = NSKeyedUnarchiver.unarchiveObject(withFile: path) else {
            return [:] // It's fine if no event collection cache exists.
        }
        
        guard let collection = fileData as? [String: [[String: Any]]] else {
            print("WARNING: Cannot read event collection at \(path)!")
            return [:]
        }
        
        cachedEvents = collection
        
        for (id, eventList) in collection {
            for eventRawData in eventList {
                guard let mainData = eventRawData["main"] as? Data else {
                    print("WARNING: Key `main` not found in event collection cache!")
                    continue
                }
                
                guard let eventMain: Data = NSData(data: mainData).aes256Decrypt(withKey: AES_KEY) else {
                    print("WARNING: Unable to decrypt event from collection cache!")
                    continue
                }
                
                if let json = try? JSON(data: eventMain) {
                    let event: Event = Event(eventInfo: json)
                    var orgSpecificEvents: [Event] = events[id] ?? []

                    // These two attributes need to be manually extracted from the JSON
                    event.hostID = json.dictionary?["Host ID"]?.string ?? event.hostID
                    event.hostTitle = json.dictionary?["Host title"]?.string ?? event.hostTitle
                    
                    event.eventVisual = eventRawData["cover"] as? UIImage
                    orgSpecificEvents.append(event)
                    
                    events[id] = orgSpecificEvents
                } else {
                    print("WARNING: Unable to parse decrypted event main data as JSON!")
                }
            }
        }
        
        return events
    }
    
    static func writeToFile(orgID: String, events: [Event], path: String) -> Bool {
        
        var collection = [[String : Any]]()
        
        for event in events {
            var eventRaw = [String : Any]()
            
            var main = JSON()
            main.dictionaryObject?["uuid"] = event.uuid
            main.dictionaryObject?["Title"] = event.title
            main.dictionaryObject?["Location"] = event.location
            
            if let startTime = event.startTime {
                main.dictionaryObject?["Start time"] = DATE_FORMATTER.string(from: startTime)
            }
            
            if let endTime = event.endTime {
                main.dictionaryObject?["End time"] = DATE_FORMATTER.string(from: endTime)
            }
            
            main.dictionaryObject?["Description"] = event.eventDescription
            
            // These two values are not part of the JSON used for initialization
            main.dictionaryObject?["Host title"] = event.hostTitle
            main.dictionaryObject?["Host ID"] = event.hostID
            main.dictionaryObject?["Published"] = event.published ? 1 : 0
            main.dictionaryObject?["Tags"] = event.tags.description
            main.dictionaryObject?["Going"] = event.currentUserGoingStatus.rawValue
            
            let mainEncrypted: Data? = NSData(data: try! main.rawData()).aes256Encrypt(withKey: AES_KEY)
            
            eventRaw["main"] = mainEncrypted
            eventRaw["cover"] = event.eventVisual
            
            collection.append(eventRaw)
        }
        
        Event.cachedEvents[orgID] = collection
        
        print(Event.cachedEvents)
        
        if NSKeyedArchiver.archiveRootObject(Event.cachedEvents, toFile: path) {
            return true
        } else {
            return false
        }
    }
    
    
    /// Verify whether an event contains all the required information for it to be published. If the event is missing some information, this function will return a non-empty string that describes the requirement.
    func verify() -> String {
        for item in [title, eventDescription, location] {
            if item.isEmpty { return "false" }
        }
        
        if title.isEmpty { return "Event title cannot be blank!" }
        
        if eventDescription.isEmpty {
            return "Event description shouldn't be blank!"
        }
        
        if location.isEmpty {
            return "You did not specify a location for your event."
        }
        
        if startTime == nil || endTime == nil {
            return "You must specify a start time and an end time."
        }
        
        if endTime!.timeIntervalSince(startTime!) <= 0 {
            return "Event end time must come after event start time."
        }
        
        if tags.isEmpty {
            return "You must select 1 - 3 tags to label your event!"
        }
        
        return ""
    }
    
}


extension Event {
    enum Going: Int {
        case neutral = 0, interested, going
    }
}


extension Event: CustomStringConvertible {
    var description: String {
        var str = "Event \"\(title)\":\n"
        str += "  uuid = \(uuid)\n"
        str += "  time = \(timeDescription)\n"
        str += "  location = \(location)\n"
        str += "  tags = \(tags.description)"
        
        return str
    }
}
