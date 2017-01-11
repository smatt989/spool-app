//
//  Adventure.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/9/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import MapKit

class Adventure: NSObject {
    
    var name = ""
    var info: String? = ""
    var id: Int?
    var markers: [Marker] = [Marker]()
    
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
}

extension Adventure {
    
    static func fetchAdventureUrl(id: Int) -> URL {
        return URL(string: Urls.fetchAdventure + String(id))!
    }
    
    struct Urls {
        static let fetchAdventure = domain+"/adventures/"
        static let saveAdventure = domain+"/adventures/save"
        static let fetchAvailableAdventures = domain+"/adventures"
    }
    
    static func fetchAdventure(id: Int, callback: @escaping (Adventure) -> Void) {
        var request = URLRequest(url: fetchAdventureUrl(id: id))
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if let d = data, let adv = self.parseAdventure(data: d) {
                callback(adv)
            } else if err != nil {
                print("BIG PROBLEMO")
            }
            }.resume()
    }
    
    private static func parseAdventure(data: Data) -> Adventure?{
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
            let adventure = Adventure()
            adventure.name = json?["name"] as? String ?? ""
            adventure.info = json?["description"] as? String
            adventure.id = json?["id"] as? Int
            let markers = (json?["markers"] as? [Any] ?? [Any]()).flatMap { element in
                parseMarker(json: element)
            }
            adventure.markers = markers
            return adventure
        }
        return nil
    }
    
    private static func parseMarker(json: Any) -> Marker? {
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
    
    static func postAdventure(adv: Adventure, callback: @escaping (Adventure) -> Void) {
        var request = URLRequest(url: URL(string: Urls.saveAdventure)!)
        request.httpMethod = "POST"
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        request.httpBody = try! JSONSerialization.data(withJSONObject: adv.toJsonDictionary(), options: [])
        let session = URLSession.shared
        print(adv.toJsonDictionary())
        session.dataTask(with: request) { data, response, err in
            if let d = data, let adv = self.parseAdventure(data: d) {
                callback(adv)
            } else if err != nil {
                print("YIKES")
            }
            }.resume()
    }

}

class Marker: NSObject {
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var id: Int?
    var title: String? = ""

    func toJsonDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        if let t = title, t != "" {
            dict["title"] = title
        }
        dict["latlng"] = ["lat": latitude, "lng": longitude]
        dict["id"] = id ?? 0
        return dict
    }
}

class Direction: NSObject {
    
    var start: Marker
    var end: Marker
    var route: MKRoute?
    
    init(start: Marker, end: Marker) {
        self.start = start
        self.end = end
        super.init()
    }
}

extension Marker: MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }

}

func ==(a: CLLocationCoordinate2D, b: CLLocationCoordinate2D) -> Bool {
    return a.latitude == b.latitude && a.longitude == b.longitude
}
