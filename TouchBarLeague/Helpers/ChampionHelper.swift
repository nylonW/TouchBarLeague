//
//  ChampionHelper.swift
//  TouchBarLeague
//
//  Created by Marcin Slusarek on 20/05/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChampionHelper {
    public static func getChampionName(by id: Int) -> String {
        let championList = NSDataAsset(name: "championList", bundle: Bundle.main)
        let jsonChampionList = String(data: championList!.data, encoding: String.Encoding.utf8)
        let json = JSON.init(parseJSON: jsonChampionList!)["keys"]
        
        return json["\(id)"].stringValue
    }
    
    public static func getChampionDisplayName(by id: Int) -> String {
        let championList = NSDataAsset(name: "championDisplayNameList", bundle: Bundle.main)
        let jsonChampionList = String(data: championList!.data, encoding: String.Encoding.utf8)
        let json = JSON.init(parseJSON: jsonChampionList!)["keys"]
        
        return json["\(id)"].stringValue
    }
}
