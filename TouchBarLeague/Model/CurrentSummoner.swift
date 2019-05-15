//
//  Summoner.swift
//  TouchBarLeague
//
//  Created by Marcin Slusarek on 14/05/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import Cocoa
import ObjectMapper

class CurrentSummoner: Mappable {
    var accountId: Int?
    var displayName: String?
    var internalName: String?
    var percentCompleteForNextLevel: Int?
    var profileIconId: Int?
    var puuid: String?
    var summonerId: Int?
    var xpSinceLastLevel: Int?
    var xpUntilNextLevel: Int?
    
    required init?(map: Map) {
        
    }
    
    //Mappable
    func mapping(map: Map) {
        accountId <- map["accountId"]
        displayName <- map["displayName"]
        internalName <- map["internalName"]
        percentCompleteForNextLevel <- map["percentCompleteForNextLevel"]
        profileIconId <- map["profileIconId"]
        puuid <- map["puuid"]
        summonerId <- map["summonerId"]
        xpSinceLastLevel <- map["xpSinceLastLevel"]
        xpUntilNextLevel <- map["xpUntilNextLevel"]
    }
}

