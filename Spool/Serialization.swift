//
//  Serialization.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/12/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import CoreLocation

extension User {
    
    static func parseMany(data: Data) -> [User] {
        var newUsers = [User]()
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let array = json as? [[String: Any]] {
            newUsers = array.flatMap{ element in
                parseUserDict(dict: element)
            }
        }
        return newUsers
    }
    
    static func parseUser(data: Data) -> User?{
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
            return parseUserDict(dict: json)
        }
        return nil
    }
    
    static func parseUserDict(dict: [String: Any]) -> User {
        let username = dict["username"] as! String
        let id = dict["id"] as! Int
        return User(username: username, id: id)
    }
}

extension UserCreate {
    
    func toJsonDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["username"] = username
        dict["email"] = email
        dict["password"] = password
        return dict
    }
}

extension UserConnectionAddRequest {
    
    func toJsonDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["addUserId"] = addUserId
        return dict
    }
}

extension UserConnectionRemoveRequest {
    func toJsonDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["removeUserId"] = removeUserId
        return dict
    }
}

extension Adventure {
    
    func toJsonDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        if name != "" {
            dict["name"] = name
        }
        if(info != ""){
            dict["description"] = info
        }
        dict["id"] = id ?? 0
        dict["markers"] = markers.map {element in element.toJsonDictionary()}
        dict["triggers"] = [Any]()
        return dict
    }
    
    static func parseAdventure(data: Data) -> Adventure?{
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
            let adventure = Adventure()
            adventure.name = json?["name"] as? String ?? ""
            adventure.info = json?["description"] as? String
            adventure.id = json?["id"] as? Int
            let markers = (json?["markers"] as? [Any] ?? [Any]()).flatMap { element in
                Marker.parseMarker(json: element)
            }
            adventure.markers = markers
            return adventure
        }
        return nil
    }
    
}

extension AdventureShareRequest {
    
    func toJsonDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["receiverUserId"] = self.shareWithUserId
        dict["adventureId"] = self.adventureId
        if let n = self.note {
            dict["note"] = n
        }
        return dict
    }
}

extension SharedAdventure {
    
    static func parse(json: Any) -> SharedAdventure? {
        if let dictionary = json as? [String: Any] {
            var adventure: AdventureHeadline?
            var sender: User?
            var receiver: User?
            let note: String? = dictionary["note"] as? String
            if let adventureJson = dictionary["adventure"] {
                adventure = AdventureHeadline.parseOneAdventure(adventureJson: adventureJson)
            }
            if let senderJson = dictionary["sender"] as? [String: Any] {
                sender = User.parseUserDict(dict: senderJson)
            }
            if let receiverJson = dictionary["receiver"] as? [String: Any] {
                receiver = User.parseUserDict(dict: receiverJson)
            }
            if let adv = adventure, let send = sender, let rec = receiver {
                return SharedAdventure(adventure: adv, sender: send, receiver: rec, note: note)
            }
        }
        return nil
    }
    
    static func parseMany(data: Data) -> [SharedAdventure] {
        var newSharedAdventures = [SharedAdventure]()
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let array = json as? [Any] {
            newSharedAdventures = array.flatMap{ element in
                parse(json: element)
            }
        }
        return newSharedAdventures
    }
}

extension AdventureHeadline {
    
    static func parseOneAdventure(adventureJson: Any) -> AdventureHeadline? {
        if let dictionary = adventureJson as? [String: Any] {
            if let title = dictionary["name"] as? String, let id = dictionary["id"] as? Int {
                let subtitle = dictionary["description"] as? String ?? ""
                let creator = User.parseUserDict(dict: dictionary["creator"] as! [String: Any])
                return AdventureHeadline(title: title, subtitle: subtitle, creator: creator, id: id)
            }
        }
        return nil
    }
}

extension AdventureHeadlineDetail {
    
    static func parseAdventures(data: Data, location: CLLocationCoordinate2D) -> [AdventureHeadlineDetail] {
        var newAdventures = [AdventureHeadlineDetail]()
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let array = json as? [[String: Any]] {
            newAdventures = array.map { element in
                parseOneAdventure(json: element, location: location)
            }
        }
        return newAdventures
    }
    
    static func parseOneAdventure(json: [String: Any], location: CLLocationCoordinate2D) -> AdventureHeadlineDetail {
        let title = json["name"] as! String
        let id = json["id"] as! Int
        let subtitle = json["description"] as? String
        let creator = User.parseUserDict(dict: json["creator"] as! [String: Any])
        let started = json["started"] as! Bool
        let finished = json["finished"] as! Bool
        var lastUpdate: NSDate?
        if let millis = json["lastUpdate"] as? Int {
            lastUpdate = NSDate(timeIntervalSince1970: TimeInterval(millis) / 1000)
        }
        let startCoordinate = Marker.parseCoordinate(json: json["startCoordinate"] as! [String: Any])
        let sharers = (json["sharers"] as! [[String: Any]]).map{element in User.parseUserDict(dict: element)}
        return AdventureHeadlineDetail(
            title: title,
            subtitle: subtitle,
            creator: creator,
            id: id,
            sharers: sharers,
            started: started,
            finished: finished,
            lastUpdate: lastUpdate,
            distance: CLLocation(latitude: startCoordinate.latitude, longitude: startCoordinate.longitude).distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
        )
    }
}

extension AdventureProgress {
    
    func toJsonDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["finished"] = finished
        dict["step"] = step
        return dict
    }
    
    static func parse(data: Data) -> AdventureProgress? {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any] {
            return AdventureProgress.parseJsonDictionary(dict: json)
        }
        return nil
    }
    
    static func parseJsonDictionary(dict: [String: Any]) -> AdventureProgress {
        let finished = dict["finished"] as! Bool
        let step = dict["step"] as! Int
        let adventureId = dict["adventureId"] as! Int
        let updated = dict["updatedAt"] as! Int
        return AdventureProgress(
            adventureId: adventureId,
            step: step,
            finished: finished,
            updated: NSDate(timeIntervalSince1970: TimeInterval(updated) / 1000)
        )
    }
}

extension Marker {
    
    func toJsonDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        if let t = title, t != "" {
            dict["title"] = title
        }
        if let desc = descriptionText {
            dict["description"] = desc
        }
        dict["showDirections"] = showDirections
        if let showBeacon = showBeaconWithinMeterRange {
            dict["showBeaconWithinMeterRange"] = showBeacon
        }
        if let showTitle = showNameWithinMeterRange {
            dict["showNameWithinMeterRange"] = showTitle
        }
        if let showDescription = showDescriptionWithinMeterRange {
            dict["showDescriptionWithinMeterRange"] = showDescription
        }
        dict["latlng"] = ["lat": latitude, "lng": longitude]
        dict["id"] = id ?? 0
        return dict
    }
    
    static func parseMarker(json: Any) -> Marker? {
        if let dictionary = json as? [String: Any] {
            let marker = Marker()
            marker.id = dictionary["id"] as? Int
            let location = parseCoordinate(json: dictionary["latlng"] as! [String: Double])
            marker.latitude = location.latitude
            marker.longitude = location.longitude
            marker.title = dictionary["title"] as? String ?? "no name"
            marker.descriptionText = dictionary["description"] as? String
            marker.showDirections = dictionary["showDirections"] as? Bool ?? true
            marker.showBeaconWithinMeterRange = dictionary["showBeaconWithinMeterRange"] as? Int
            marker.showNameWithinMeterRange = dictionary["showNameWithinMeterRange"] as? Int
            marker.showDescriptionWithinMeterRange = dictionary["showDescriptionWithinMeterRange"] as? Int
            return marker
        }
        return nil
    }
    
    static func parseCoordinate(json: [String: Any]) -> CLLocationCoordinate2D {
        let latitude = json["lat"] as! Double
        let longitude = json["lng"] as! Double
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
