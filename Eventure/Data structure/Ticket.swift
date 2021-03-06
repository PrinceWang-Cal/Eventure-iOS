//
//  Ticket.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/15.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class Ticket {
    
    static var allTickets = [Int: [[String : Any]]]()
    static var userTickets = Set<Ticket>()
    
    var ticketID: String
    var userID: Int
    var eventID: String
    var eventName: String
    var hostName: String
    var hostID: String
    var paymentType: PaymentType = .none
    var quantity: Int
    var ticketPrice: Double
    var paymentAmount: Double
    var admissionType: String
    var eventDate: Date?
    var eventEndDate: Date?
    var transactionDate: Date?
    var activationDate: Date?
    var notes: String
    
    let hasLogo: Bool
    var orgLogo: UIImage?
    var eventCover: UIImage?
    var associatedEvent: Event?
    
    required init(ticketInfo: JSON) {
        let dictionary = ticketInfo.dictionaryValue
        
        ticketID = dictionary["Ticket ID"]?.string ?? ""
        userID = dictionary["User ID"]?.int ?? -1
        eventID = dictionary["Event ID"]?.string ?? ""
        eventName = dictionary["Event title"]?.string ?? ""
        hostName = dictionary["Organization title"]?.string ?? ""
        hostID = dictionary["Organization"]?.string ?? ""
        hasLogo = (dictionary["Has logo"]?.int ?? 0) == 1
        admissionType = dictionary["Admission type"]?.string ?? "Unspecified"
        quantity = dictionary["Quantity"]?.int ?? 1
        ticketPrice = dictionary["Ticket price"]?.double ?? 0.0
        paymentAmount = dictionary["Payment amount"]?.double ?? 0.0
        notes = dictionary["Notes"]?.string ?? ""
        
        if let eventDateString = dictionary["Start time"]?.string {
            eventDate = DATE_FORMATTER.date(from: eventDateString)
        }
        
        if let endString = dictionary["End time"]?.string {
            eventEndDate = DATE_FORMATTER.date(from: endString)
        }
        
        if let dateString = dictionary["Transaction date"]?.string {
            transactionDate = DATE_FORMATTER.date(from: dateString)
        }
        
        if let activationDateString = dictionary["Activation date"]?.string {
            activationDate = DATE_FORMATTER.date(from: activationDateString)
        }
        
        if let paymentRaw = dictionary["Payment type"]?.string {
            paymentType = PaymentType(rawValue: paymentRaw) ?? .none
        }
        
    }
    
    private var encodedJSON: JSON {
        var main = JSON()
        
        main.dictionaryObject?["Ticket ID"] = ticketID
        main.dictionaryObject?["User ID"] = userID
        main.dictionaryObject?["Event ID"] = eventID
        main.dictionaryObject?["Event title"] = eventName
        main.dictionaryObject?["Organization title"] = hostName
        main.dictionaryObject?["Organization"] = hostID
        main.dictionaryObject?["Quantity"] = quantity
        main.dictionaryObject?["Payment amount"] = paymentAmount
        main.dictionaryObject?["Payment type"] = paymentType.rawValue
        main.dictionaryObject?["Has logo"] = hasLogo ? 1 : 0
        
        if activationDate != nil {
            main.dictionaryObject?["Activation date"] = DATE_FORMATTER.string(from: activationDate!)
        }

        
        if eventDate != nil {
            main.dictionaryObject?["Start time"] = DATE_FORMATTER.string(from: eventDate!)
        }
        
        if eventEndDate != nil {
            main.dictionaryObject?["End time"] = DATE_FORMATTER.string(from: eventEndDate!)
        }
        
        if transactionDate != nil {
            main.dictionaryObject?["Transaction date"] = DATE_FORMATTER.string(from: transactionDate!)
        }
        
        return main
    }
    
    func fetchEventImage(_ handler: ((Ticket) -> ())?) {
        if !hasLogo { return }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetEventCover",
                           parameters: ["uuid": eventID])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                return // Don't display any alert here
            }
            
            self.eventCover = UIImage(data: data!)
            DispatchQueue.main.async {
                handler?(self)
            }
        }
        
        task.resume()
    }
    
    func getEvent(handler: ((Bool) -> ())?) {
        
        guard associatedEvent == nil else {
            handler?(true)
            return
        }
        
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/GetEvent",
                           parameters: ["uuid": eventID])!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    handler?(false)
                }
                return
            }
            
            if let eventDictionary = try? JSON(data: data!) {
                let event = Event(eventInfo: eventDictionary)
                self.associatedEvent = event
                event.eventVisual = self.eventCover
                
                DispatchQueue.main.async {
                    handler?(true)
                }
                
            } else {
                DispatchQueue.main.async {
                    handler?(false)
                }
            }
        }
        
        task.resume()
    }
    
    func save() {
        Ticket.writeToFile(userID: userID)
    }
    
    @discardableResult static func writeToFile(userID: Int) -> Bool {
        
        var collection = [[String : Any]]()
        
        for ticket in userTickets {
            var ticketInfo = [String : Any]()
            
            let mainEncrypted: Data? = NSData(data: try! ticket.encodedJSON.rawData()).aes256Encrypt(withKey: AES_KEY)
            
            ticketInfo["main"] = mainEncrypted
            ticketInfo["org logo"] = ticket.orgLogo
            
            collection.append(ticketInfo)
        }
        
        allTickets[userID] = collection
        
        if NSKeyedArchiver.archiveRootObject(allTickets, toFile: TICKETS_PATH) {
            return true
        } else {
            return false
        }
    }
    
    static func readFromFile() -> [Int: Set<Ticket>] {
        
        var tickets = [Int: Set<Ticket>]()
        
        guard let fileData = NSKeyedUnarchiver.unarchiveObject(withFile: TICKETS_PATH) else {
            return [:] // It's fine if no event collection cache exists.
        }
        
        guard let collection = fileData as? [Int: [[String : Any]]] else {
            print("WARNING: Cannot read tickets at \(TICKETS_PATH)!")
            return [:]
        }
        
        allTickets = collection
        
        for (id, ticketsList) in collection {
            for ticketInfo in ticketsList {
                guard let mainData = ticketInfo["main"] as? Data else {
                    print("WARNING: Key `main` not found for user ID \(id) in ticket cache!")
                    continue
                }
                
                guard let decryptedMain: Data = NSData(data: mainData).aes256Decrypt(withKey: AES_KEY) else {
                    print("WARNING: Unable to decrypt tickets for user \(id)!")
                    continue
                }
                
                if let json = try? JSON(data: decryptedMain) {
                    let ticket: Ticket = Ticket(ticketInfo: json)
                    var userSpecificTickets: Set<Ticket> = tickets[id] ?? []
                    
                    ticket.orgLogo = ticketInfo["org logo"] as? UIImage
                    userSpecificTickets.insert(ticket)
                    
                    tickets[id] = userSpecificTickets
                } else {
                    print("WARNING: Unable to parse decrypted ticket main data as JSON!")
                }
            }
        }
        
        return tickets
    }
}


extension Ticket: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ticketID)
    }
    
    static func ==(lhs: Ticket, rhs: Ticket) -> Bool {
        return lhs.ticketID == rhs.ticketID
    }
}


extension Ticket {
    enum PaymentType: String {
        case offline = "Offline"
        case venmo = "Venmo"
        case credit = "Credit/debit card"
        case paypal = "Paypal"
        case none = "N/A"
    }
}
