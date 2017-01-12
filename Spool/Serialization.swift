//
//  Serialization.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/12/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation

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
                return AdventureHeadline(title: title, subtitle: subtitle, id: id)
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
            return marker
        }
        return nil
    }
}
