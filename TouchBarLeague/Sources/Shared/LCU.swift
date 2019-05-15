//
//  LCU.swift
//  TouchBarLeague
//
//  Created by Marcin Slusarek on 15/05/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class LCU {
    
    let findLolPathCommand = "ps x -o comm= | grep 'LeagueClientUx'"
    var lolPath: String?
    var summonerId: Int?
    var summonerDisplayName: String?
    var detected = false
    
    static let shared = LCU()
    
    private init() {
        authenticateLcu()
    }
    
  
    func authenticateLcu() {
        lolPath = findLolPathCommand.shell()
        lolPath = lolPath?.components(separatedBy: "/RADS")[0] ?? ""
        let lockfile = "head \"\(lolPath ?? "")/lockfile\"".shell()
        print(lockfile)
        
        if lockfile == "" {
            return
        }
        detected = true
        let credentials = lockfile.split(separator: ":")
        let header = "Basic \("riot:\(credentials[3])".toBase64())"
        let acceptHeader = HTTPHeader(name: "Accept", value: "application/json")
        let headers = HTTPHeaders([HTTPHeader(name: "Authorization", value: header), acceptHeader])
        print(header)
        
        RequestWrapper.requestGETURL(Constants.endpoints.getCurrentSummoner(withPort: String(credentials[2])), headers: headers, success: { (JSONResponse) in
            if let summoner = Mapper<CurrentSummoner>().map(JSONString: JSONResponse) {
                guard let summonerId = summoner.summonerId else { return }
                self.summonerId = summonerId
                print(summonerId)
                
                guard let summonerDisplayName = summoner.displayName else { return }
                self.summonerDisplayName = summonerDisplayName
                print(summonerDisplayName)
                
                print("successfully get current summoner")
            }
        }, failure: { (error) in
            print("failed...")
            print(error)
        })
    }
}
