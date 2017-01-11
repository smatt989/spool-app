//
//  AdventureHeadline.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/9/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation

struct AdventureHeadline {
    var title = ""
    var subtitle = ""
    var id = 0
}

extension AdventureHeadline {
    
    static func fetchAdventures(callback: @escaping ([AdventureHeadline]) -> Void){
        var request = URLRequest(url: URL(string: Adventure.Urls.fetchAvailableAdventures)!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if let d = data {
                let advs = self.parseAdventures(data: d)
                callback(advs)
            } else if err != nil {
                print("BIG PROBLEMO")
            }
            }.resume()
    }
    
    private static func parseAdventures(data: Data) -> [AdventureHeadline] {
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
