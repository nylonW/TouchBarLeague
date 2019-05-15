//
//  Champion1vs9.swift
//  TouchBarLeague
//
//  Created by Marcin Slusarek on 16/05/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import Foundation
import ObjectMapper

class Champion1vs9: Mappable {
    var role: String?
    var highestCountRuneHash: String?
    var itemhash: String?
    
    required init?(map: Map) {
        
    }
    
    //Mappable
    func mapping(map: Map) {
        role <- map["role"]
        highestCountRuneHash <- map["runehash"]
        itemhash <- map["itemhash"]
    }
}
