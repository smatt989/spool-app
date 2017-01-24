//
//  Serialization.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/12/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation

extension User {
    
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

extension AdventureHeadline {
    
    static func parseAdventures(data: Data) -> [AdventureHeadline] {
        var newAdventures = [AdventureHeadline]()
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let array = json as? [Any]{
            newAdventures = array.flatMap {element in
                parseOneAdventure(adventureJson: element)
            }
        }
        return newAdventures
    }
    
    private static func parseOneAdventure(adventureJson: Any) -> AdventureHeadline? {
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
            var location = dictionary["latlng"] as! [String: Double]
            marker.latitude = location["lat"]!
            marker.longitude = location["lng"]!
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
}
