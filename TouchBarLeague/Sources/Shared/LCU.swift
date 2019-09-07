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
import RxCocoa

class LCU {
    
    let findLolPathCommand = "ps x -o comm= | grep 'LeagueClientUx'"
    var lolPath: String?
    var summonerId: Int?
    var summonerDisplayName: String?
    let detected: BehaviorRelay<Bool> = BehaviorRelay(value : false)
    var port: String?
    var riotPassword: String?
    
    static let shared = LCU()
    
    private init() {
        authenticateLcu()
    }
    
  
    func authenticateLcu() {
        //lolPath = findLolPathCommand.shell().split(separator: "\n"))
        //lolPath = lolPath?.components(separatedBy: "/RADS")[0] ?? ""
        lolPath = "/Applications/League of Legends.app/Contents/LoL"
        let lockfile = "head \"\(lolPath ?? "")/lockfile\"".shell()
        print(lockfile)
        
        if lockfile == "" {
            return
        }
        
        let credentials = lockfile.split(separator: ":")
        port = String(credentials[2])
        riotPassword = "\(credentials[3])"
        detected.accept(true)
        
        loadSummoner()
    }
    
    func loadSummoner() {
        guard let password = riotPassword else { return }
        let header = "Basic \("riot:\(password)".toBase64())"
        let headers = HTTPHeaders([HTTPHeader(name: "Authorization", value: header)])
        print(header)
        
        RequestWrapper.requestGETURL(Constants.endpoints.getCurrentSummoner(withPort: port ?? ""), headers: headers, success: { (JSONResponse) in
            if let summoner = Mapper<CurrentSummoner>().map(JSONString: JSONResponse) {
                guard let summonerId = summoner.summonerId else { return }
                self.summonerId = summonerId
                print(summonerId)
                
                guard let summonerDisplayName = summoner.displayName else { return }
                self.summonerDisplayName = summonerDisplayName
                print(summonerDisplayName)
                
                print("Successfully get current summoner")
            }
        }, failure: { (error) in
            print("failed.")
            print(error)
        })
    }
}
