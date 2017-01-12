//
//  HttpRequests.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/12/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation

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
}

