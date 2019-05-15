//
//  Constants.swift
//  TouchBarLeague
//
//  Created by Marcin Slusarek on 14/05/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import Foundation

class Constants {
    struct endpoints {
        public static func getCurrentSummoner(withPort port: String) -> String {
            return "https://127.0.0.1:\(port)/lol-summoner/v1/current-summoner"
        }
    }
}
