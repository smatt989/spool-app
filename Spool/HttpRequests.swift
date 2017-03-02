//
//  HttpRequests.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/12/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

extension User {
    
    struct Headers {
        static let sessionHeader = "Spool-Session-Key"
        static let usernameHeader = "username"
        static let passwordHeader = "password"
    }
    
    static func signUp(newUser: UserCreate, success: @escaping (User) -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Adventure.Urls.createUser)!)
        request.httpMethod = "POST"
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        request.httpBody = try! JSONSerialization.data(withJSONObject: newUser.toJsonDictionary(), options: [])
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if let d = data, let user = self.parseUser(data: d) {
                //need to get header and save session key (or maybe not here)
                DispatchQueue.main.async {
                    success(user)
                }
            } else if err != nil {
                DispatchQueue.main.async {
                    failure(err!)
                }
            }
        }.resume()
    }
    
    static func saveDeviceToken(_ token: String, success: @escaping (Void) -> Void, failure: @escaping (Error) -> Void){
        var request = URLRequest(url: URL(string: Adventure.Urls.deviceToken+"?device_token="+token)!)
        request.httpMethod = "POST"
        request.authenticate()
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            if data != nil {
                DispatchQueue.main.async {
                    success()
                }
            } else if err != nil {
                DispatchQueue.main.async {
                    failure(err!)
                }
            }
        }.resume()
    }
    
    static func checkSession(managedObjectContext: NSManagedObjectContext, success: @escaping (User) -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Adventure.Urls.login)!)
        request.httpMethod = "GET"
        request.authenticate()
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if let key = (response as? HTTPURLResponse)?.allHeaderFields[Headers.sessionHeader] as? String, let userData = data {
                _ = Session.setSessionKey(key: key, managedObjectContext: managedObjectContext)
                DispatchQueue.main.async {
                    success(User.parseUser(data: userData)!)
                }
            } else if err != nil{
                Session.removeSessionKey(managedObjectContext: managedObjectContext)
                DispatchQueue.main.async {
                    failure(err!)
                }
            } else {
                print("SOMETHING STRANGE")
                let error = NSError()
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }.resume()
    }
    
    static func login(username: String, password: String, managedObjectContext: NSManagedObjectContext, success: @escaping (User) -> Void, failure: @escaping (Error) -> Void){
        var request = URLRequest(url: URL(string: Adventure.Urls.login)!)
        request.httpMethod = "GET"
        request.addValue(username, forHTTPHeaderField: Headers.usernameHeader)
        request.addValue(password, forHTTPHeaderField: Headers.passwordHeader)
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if let key = (response as? HTTPURLResponse)?.allHeaderFields[Headers.sessionHeader] as? String
, let userData = data {
                _ = Session.setSessionKey(key: key, managedObjectContext: managedObjectContext)
                DispatchQueue.main.async {
                    success(User.parseUser(data: userData)!)
                }
            } else if err != nil{
                print("UNO PROBLEMO")
                DispatchQueue.main.async {
                    failure(err!)
                }
            } else {
                print("SOMETHING ELSE...")
            }
        }.resume()
    }
    
    static func logout(callback: @escaping () -> Void){
        var request = URLRequest(url: URL(string: Adventure.Urls.logout)!)
        request.httpMethod = "POST"
        request.authenticate()
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            DispatchQueue.main.async{
                callback()
            }
        }.resume()
    }
    
    static func search(query: String, success: @escaping ([User]) -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Adventure.Urls.usersSearch+"?query="+query)!)
        request.httpMethod = "POST"
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            if let d = data {
                let users = User.parseMany(data: d)
                success(users)
            } else if err != nil {
                failure(err!)
            } else {
                print("WHOOPS")
            }
        }.resume()
    }
    
    static func addedUsers(success: @escaping ([User]) -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Adventure.Urls.addedUsers)!)
        request.httpMethod = "GET"
        request.authenticate()
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if let d = data {
                let users = User.parseMany(data: d)
                success(users)
            } else if err != nil {
                failure(err!)
            } else {
                print("BRARRR")
            }
        }.resume()
    }
    
    static func awaitingUsers(success: @escaping ([User]) -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Adventure.Urls.awaitingConnections)!)
        request.httpMethod = "GET"
        request.authenticate()
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            if let d = data {
                let users = User.parseMany(data: d)
                success(users)
            } else if err != nil {
                failure(err!)
            } else {
                print("MEEEEEEERRRRK")
            }
        }.resume()
    }
    
    static func addUser(addUserRequest: UserConnectionAddRequest, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Adventure.Urls.addUserConnection)!)
        request.httpMethod = "POST"
        request.authenticate()
        request.jsonRequest()
        request.httpBody = try! JSONSerialization.data(withJSONObject: addUserRequest.toJsonDictionary(), options: [])
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            if data != nil {
                success()
            } else if err != nil {
                failure(err!)
            } else {
                print("MOOSH")
            }
        }.resume()
    }
    
    static func removeUser(removeUserRequest: UserConnectionRemoveRequest, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Adventure.Urls.removeUserConnection)!)
        request.httpMethod = "POST"
        request.authenticate()
        request.jsonRequest()
        request.httpBody = try! JSONSerialization.data(withJSONObject: removeUserRequest.toJsonDictionary(), options: [])
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            if data != nil {
                success()
            } else if err != nil {
                failure(err!)
            } else {
                print("MOOSH")
            }
        }.resume()
    }
}

extension Adventure {
    
    static func fetchAdventureUrl(id: Int) -> URL {
        return URL(string: Urls.fetchAdventure + String(id))!
    }
    
    struct Urls {
        static let createUser = domain+"/users/create"
        static let login = domain+"/sessions/new"
        static let logout = domain+"/sessions/logout"
        static let fetchAdventure = domain+"/adventures/"
        static let saveAdventure = domain+"/adventures/save"
        static let fetchDetailedAvailableAdventures = domain+"/users/adventures"
        static let fetchOneDetailedAdventure = domain+"/users/adventures/"
        static let usersSearch = domain+"/users/search"
        static let addUserConnection = domain+"/users/connections/create"
        static let removeUserConnection = domain+"/users/connections/delete"
        static let addedUsers = domain+"/users/connections/added"
        static let awaitingConnections = domain+"/users/connections/awaiting"
        static let shareAdventures = domain+"/adventures/share"
        static let sharedAdventures = domain+"/adventures/shared"
        static let receivedAdventures = domain+"/adventures/received"
        static let createAdventureProgress = domain+"/adventures/"
        static let getCurrentProgress = domain+"/adventures/"
        static let deviceToken = domain+"/users/tokens"
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
        request.jsonRequest()
        request.authenticate()
        request.httpBody = try! JSONSerialization.data(withJSONObject: adv.toJsonDictionary(), options: [])
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if let d = data, let adv = self.parseAdventure(data: d) {
                callback(adv)
            } else if err != nil {
                print("YIKES")
            }
        }.resume()
    }
}

extension AdventureShareRequest {
    static func shareMany(_ shareRequests: [AdventureShareRequest], success: @escaping() -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Adventure.Urls.shareAdventures)!)
        request.httpMethod = "POST"
        request.authenticate()
        request.jsonRequest()
        request.httpBody = try! JSONSerialization.data(withJSONObject: shareRequests.map{$0.toJsonDictionary()}, options: [])
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if data != nil {
                success()
            } else if err != nil {
                failure(err!)
            } else {
                print("bad")
            }
        }.resume()
    }
}

extension SharedAdventure {
    static func adventuresShared(success: @escaping ([SharedAdventure]) -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Adventure.Urls.sharedAdventures)!)
        request.httpMethod = "GET"
        request.authenticate()
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            if let d = data {
                let shared = self.parseMany(data: d)
                success(shared)
            } else if err != nil {
                failure(err!)
            } else {
                print("huh")
            }
        }.resume()
    }
    
    static func adventuresReceived(success: @escaping ([SharedAdventure]) -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Adventure.Urls.receivedAdventures)!)
        request.httpMethod = "GET"
        request.authenticate()
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            if let d = data {
                let shared = self.parseMany(data: d)
                success(shared)
            } else if err != nil {
                failure(err!)
            } else {
                print("huh")
            }
        }.resume()
    }
}

extension AdventureProgress {
    
    static func create(_ update: AdventureProgress, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Adventure.Urls.createAdventureProgress+String(update.adventureId)+"/progress/create")!)
        request.httpMethod = "POST"
        request.authenticate()
        request.jsonRequest()
        request.httpBody = try! JSONSerialization.data(withJSONObject: update.toJsonDictionary(), options: [])
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if data != nil {
                success()
            } else if err != nil {
                failure(err!)
            } else {
                print("BLOOOOP")
            }
        }.resume()
    }
    
    static func get(adventureId: Int, success: @escaping (AdventureProgress) -> Void, failure: @escaping (Error) -> Void) {
        var request = URLRequest(url: URL(string: Adventure.Urls.getCurrentProgress+String(adventureId)+"/progress/current")!)
        request.httpMethod = "GET"
        request.authenticate()
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if let d = data, let progress = AdventureProgress.parse(data: d) {
                success(progress)
            } else if err != nil {
                failure(err!)
            } else {
                print("ALL EFFED")
            }
        }.resume()
    }
}

extension AdventureHeadlineDetail {
    
    static func fetchAdventures(location: CLLocationCoordinate2D, callback: @escaping ([AdventureHeadlineDetail]) -> Void) {
        var request = URLRequest(url: URL(string: Adventure.Urls.fetchDetailedAvailableAdventures)!)
        request.httpMethod = "POST"
        request.authenticate()
        request.jsonRequest()
        request.httpBody = try! JSONSerialization.data(withJSONObject: Marker.latLng(lat: location.latitude, lng: location.longitude))
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, err in
            if let d = data {
                let advs = self.parseAdventures(data: d, location: location)
                print("THISMANY OF THEM \(advs.count)")
                callback(advs)
            } else if err != nil {
                print("BIG PROBLEMO")
            }
        }.resume()
    }
    
    static func fetchOneAdventure(adventureId: Int, location: CLLocationCoordinate2D, callback: @escaping (AdventureHeadlineDetail) -> Void ) {
        var request = URLRequest(url: URL(string: Adventure.Urls.fetchOneDetailedAdventure+String(adventureId))!)
        request.httpMethod = "GET"
        request.authenticate()
        let session = URLSession.shared
        session.dataTask(with: request) {data, response, err in
            if let d = data {
                let adv = self.parseOneAdventureData(data: d, location: location)
                callback(adv)
            } else if err != nil {
                print("ERROR")
            } else {
                print("WAWAWA")
            }
        }.resume()
    }
}

extension URLRequest {
    mutating func jsonRequest() {
        self.addValue("application/json",forHTTPHeaderField: "Content-Type")
        self.addValue("application/json",forHTTPHeaderField: "Accept")
    }
}

