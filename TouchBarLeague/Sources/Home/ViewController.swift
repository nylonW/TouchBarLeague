//
//  ViewController.swift
//  TouchBarLeague
//
//  Created by Marcin Slusarek on 13/05/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import Cocoa
import Foundation
import AppKit
import TouchBarHelper
import ObjectMapper
import Alamofire
import RxSwift
import RxCocoa
import SocketRocket
import SwiftyJSON
import Kingfisher

private let kSummonerNameIdentifier = NSTouchBarItem.Identifier("item.summonerName")
private let kPandaIdentifier = NSTouchBarItem.Identifier("item.")
private let kGroupIdentifier = NSTouchBarItem.Identifier("io.a2.Group")

class ViewController: NSViewController, NSTouchBarDelegate, SRWebSocketDelegate {
    
    var socketrocket: SRWebSocket?
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        if let mess = message {
            //print(mess)
            getChampionSelect()
        }
    }
    func webSocket(_ webSocket: SRWebSocket!, didReceivePong pongPayload: Data!) {
        print(pongPayload)
        print("pomn")
    }
    
    
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        print(error)
        print("fail")
    }
    
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        print("open")
        socketrocket?.send("[5, \"OnJsonApiEvent_lol-champ-select_v1_current-champion\"]")
        socketrocket?.send("[5, \"OnJsonApiEvent_lol-champ-select_v1_session\"]")
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        print(reason)
        print("reason")
    }
    
    //MARK: - Properties
    
    @IBOutlet weak var detectingLabel: NSTextField!
    
    let pickedChampion: BehaviorRelay<Int> = BehaviorRelay(value : 0)
    let disposeBag = DisposeBag()
    var currentTouchBarItem: NSCustomTouchBarItem?
    var groupTouchBar = NSTouchBar()
    var groupTouchBarA: NSTouchBar {
        let groupTouchBar = NSTouchBar()
        groupTouchBar.defaultItemIdentifiers = [kSummonerNameIdentifier, kPandaIdentifier]
        groupTouchBar.delegate = self
        
        return groupTouchBar
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        print(LCU.shared)
        
        setupTouchBar()
        
        pickedChampion.asObservable().debounce(.milliseconds(200), scheduler: MainScheduler.instance).subscribe(onNext: {_ in
            print(self.pickedChampion.value)
            if self.pickedChampion.value > 0 {
                self.setTouchBarRunes(for: self.pickedChampion.value)
                let tbButton = self.currentTouchBarItem?.view as? NSButton
                tbButton?.kf.setImage(with: URL(string: "https://ddragon.leagueoflegends.com/cdn/\(Constants.lolConstants.lolVersion)/img/champion/\(ChampionHelper.getChampionName(by: self.pickedChampion.value)).png"))
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        if LCU.shared.detected {
            detectingLabel.stringValue = "LoLClient detected"
        } else {
            detectingLabel.stringValue = "Couldn't detect LoLClient"
        }
        
        let basic = "Basic \("riot:\(LCU.shared.riotPassword ?? "")".toBase64())"
        var requestSR = URLRequest(url: URL(string: "wss://riot:\(LCU.shared.riotPassword ?? "")@127.0.0.1:\(LCU.shared.port ?? "")/")!)
        requestSR.setValue(basic, forHTTPHeaderField: "Authorization")
        socketrocket = SRWebSocket(urlRequest: requestSR, protocols: ["wamp", "https"], allowsUntrustedSSLCertificates: true)
        socketrocket?.delegate = self
        socketrocket?.open()
        
    }
    //MARK: - Handlers
  
    fileprivate func setupTouchBar() {
        DFRSystemModalShowsCloseBoxWhenFrontMost(true)
        
        let panda = NSCustomTouchBarItem(identifier: kPandaIdentifier)
        panda.view = NSButton(image: #imageLiteral(resourceName: "5005"), target: self, action: #selector(self.present(_:)))
        currentTouchBarItem = panda
        NSTouchBarItem.addSystemTrayItem(panda)
        
        DFRElementSetControlStripPresenceForIdentifier(kPandaIdentifier, true)
    }
    //        NSTouchBarItem.removeSystemTrayItem(currentTouchBarItem)
   
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        if identifier == kSummonerNameIdentifier {
            let bear = NSCustomTouchBarItem(identifier: kSummonerNameIdentifier)
            bear.view = NSButton(title: LCU.shared.summonerDisplayName ?? "Login to league", target: self, action: #selector(self.bear(_:)))
            return bear
        } else if (identifier == kPandaIdentifier) {
            let panda = NSCustomTouchBarItem(identifier: kPandaIdentifier)
            panda.view = NSButton(title: "🥺", target: self, action: #selector(self.bear(_:)))
            return panda
        } else {
            let perkButton = NSCustomTouchBarItem(identifier: identifier)
            let button = NSButton(title: "", target: self, action: #selector(self.bear(_:)))
            button.image = NSImage(named: "\(identifier.rawValue)")?.resized(to: CGSize(width: 30, height: 30))
            perkButton.view = button
            return perkButton
        }
    }
    
    @objc func bear(_ sender: Any?) {
        print("First button clicked")
    }
    
    @objc func present(_ sender: Any?) {
        if self.pickedChampion.value != 0  {
            setTouchBarRunes(for: self.pickedChampion.value)
        }
    }
    
    
    @IBAction func loadRunesToTouchBar(_ sender: Any) {
        getChampionSelect()
    }
    
    func getChampionSelect() {
        let header = "Basic \("riot:\(LCU.shared.riotPassword ?? "")".toBase64())"
        let acceptHeader = HTTPHeader(name: "Accept", value: "application/json")
        let headers = HTTPHeaders([HTTPHeader(name: "Authorization", value: header), acceptHeader])
        RequestWrapper.requestGETURL(Constants.endpoints.getCurrentChampionSelect(withPort: LCU.shared.port ?? ""), headers: headers, success: { (JSONResponse) in
            var response: JSON?
            if let dataFromString = JSONResponse.data(using: .utf8, allowLossyConversion: false) {
                response = try? JSON(data: dataFromString)
            }
            if let playerList = Mapper<MyTeam>().mapArray(JSONString: response?["myTeam"].rawString() ?? "") {
                for player in playerList {
                    if player.summonerId == LCU.shared.summonerId {
                        if player.championId != self.pickedChampion.value {
                            self.pickedChampion.accept(player.championId ?? 0)
                        }
                    }
                }
            }
        }, failure: { (error) in
            print(error)
        })
    }
    
    fileprivate func reloadTouchBar(_ touchBar: NSTouchBar) {
        self.touchBar?.dismissSystemModal()
        if #available(OSX 10.14, *) {
            NSTouchBar.dismissSystemModalTouchBar(self.groupTouchBar)
        } else {
            NSTouchBar.dismissSystemModalFunctionBar(self.groupTouchBar)
        }
        //NSTouchBarItem.removeSystemTrayItem(currentTouchBarItem)
        self.groupTouchBar.dismissSystemModal()
        self.groupTouchBar = touchBar
        if #available(macOS 10.14, *) {
            NSTouchBar.presentSystemModalTouchBar(self.groupTouchBar, systemTrayItemIdentifier: kPandaIdentifier)
        } else {
            NSTouchBar.presentSystemModalFunctionBar(self.groupTouchBar, systemTrayItemIdentifier: kPandaIdentifier)
        }
    }
    
    func setTouchBarRunes(for id: Int) {
        RequestWrapper.requestGETURL(Constants.endpoints.getRunehashFromAPI(id: id), success: { (JSONResponse) in
            if let champion = Mapper<Champion1vs9>().mapArray(JSONString: JSONResponse) {
                print(champion[0].highestCountRuneHash ?? "Failed to download runes")
                self.reloadTouchBar(self.runeTouchBar(champion[0].highestCountRuneHash ?? ""))
            }
        }, failure: { (error) in
            print(error)
        })
    }
    
    func runeTouchBar(_ runehash: String) -> NSTouchBar {
        let groupTouchBar = NSTouchBar()
        let perks = runehash.split(separator: "-")
        
        let perksIdentifiers = perks.map { NSTouchBarItem.Identifier(String($0)) }.orderedSet
        
        groupTouchBar.defaultItemIdentifiers = perksIdentifiers
        groupTouchBar.delegate = self
        
        return groupTouchBar
    }
}

