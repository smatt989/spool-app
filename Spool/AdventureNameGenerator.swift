//
//  AdventureNameGenerator.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/30/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation

class AdventureNameGenerator {
    
    func generateRandomAdventureName() -> String {
        let adverbIndex = Int(arc4random_uniform(UInt32(adventureAdverbs.count)))
        let adjectiveIndex = Int(arc4random_uniform(UInt32(adventureAdjectives.count)))
        let nounIndex = Int(arc4random_uniform(UInt32(adventureNouns.count)))
        
        return "\(adventureAdverbs[adverbIndex]) \(adventureAdjectives[adjectiveIndex]) \(adventureNouns[nounIndex])".capitalized
    }
    
    private let adventureAdjectives = [
        "exciting",
        "amazing",
        "unique",
        "dangerous",
        "rugged",
        "critical",
        "impossible",
        "dramatic",
        "courageous",
        "inspiring",
        "selfless",
        "life-altering",
        "terrific",
        "perilous"
    ]
    
    private let adventureNouns = [
        "adventure",
        "quest",
        "voyage",
        "exploration",
        "feat",
        "enterprise",
        "undertaking"
    ]
    
    private let adventureAdverbs = [
        "amazingly",
        "tremendously",
        "extremely",
        "somewhat",
        "unusually",
        "impossibly",
        "uniquely",
        "strangely",
        "most",
        "absolutely",
        "heroicly"
    ]
}
