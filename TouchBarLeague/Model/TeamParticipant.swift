//
//  MyTeam.swift
//  TouchBarLeague
//
//  Created by Marcin Slusarek on 16/05/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import Foundation
import ObjectMapper

class TeamParticipant: Mappable {
    
    var summonerId: Int?
    var championId: Int?
    var cellId: Int?
    var team: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        championId <- map["championId"]
        summonerId <- map["summonerId"]
        cellId <- map["cellId"]
        team <- map["team"]
    }
}
