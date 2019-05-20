//
//  Constants.swift
//  TouchBarLeague
//
//  Created by Marcin Slusarek on 14/05/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import Foundation

class Constants {
    
    struct lolConstants {
        public static let lolVersion = "9.10.1"
    }
    
    struct endpoints {
        public static func getCurrentSummoner(withPort port: String) -> String {
            return "https://127.0.0.1:\(port)/lol-summoner/v1/current-summoner"
        }
        
        public static func getCurrentChampionSelect(withPort port: String) -> String {
            return "https://127.0.0.1:\(port)/lol-champ-select/v1/session"
        }
        
        public static func getRunehashFromAPI(id championId: Int) -> String {
            return "http://1vs9.net:8080/LOLAPI/rest/runehash?id=\(championId)"
        }
    }
}
