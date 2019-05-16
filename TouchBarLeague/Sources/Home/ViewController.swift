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
import Starscream
import Swamp

private let kSummonerNameIdentifier = NSTouchBarItem.Identifier("item.summonerName")
private let kPandaIdentifier = NSTouchBarItem.Identifier("item.")
private let kGroupIdentifier = NSTouchBarItem.Identifier("io.a2.Group")

class ViewController: NSViewController, NSTouchBarDelegate, WebSocketDelegate, SwampSessionDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("WebSocket connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("WebSocket disconnected")
        print(error)

    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("WebSocket receives a message")
        print(text)

    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("WebSocket receives a data")

    }
    

    //MARK: - Properties
    
    @IBOutlet weak var detectingLabel: NSTextField!
    
    var socket: WebSocket?
    var swampSession: SwampSession?
    
    var currentTouchBarItem: NSCustomTouchBarItem?
    var groupTouchBar = NSTouchBar()
    var groupTouchBarA: NSTouchBar {
        let groupTouchBar = NSTouchBar()
        groupTouchBar.defaultItemIdentifiers = [kSummonerNameIdentifier, kPandaIdentifier]
        groupTouchBar.delegate = self
        self.groupTouchBar = groupTouchBar
        
        return self.groupTouchBar
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
        
        if LCU.shared.detected {
            detectingLabel.stringValue = "LoLClient detected"
        } else {
            detectingLabel.stringValue = "Couldn't detect LoLClient"
        }
        
        let swampTransport = WebSocketSwampTransport(wsEndpoint:  URL(string: "ws://my-router.com:8080/ws")!)
        swampSession = SwampSession(realm: "router-defined-realm", transport: swampTransport)
        // Set delegate for callbacks
        swampSession?.delegate = self
        swampSession?.connect()
        
        
        
//        let basic = "Basic \("riot:\(LCU.shared.riotPassword ?? "")".toBase64())"
//        let login = "riot:\(LCU.shared.riotPassword ?? "")"
//        var request = URLRequest(url: URL(string: "wss://127.0.0.1:\(LCU.shared.port ?? "")/")!)
//        //request.timeoutInterval = 5
//        request.setValue(basic, forHTTPHeaderField: "Authorization")
//        print()
//
//        //socket = WebSocket(url: URL(string: "wss://riot:\(LCU.shared.riotPassword ?? "")@127.0.0.1:\(LCU.shared.port ?? "")/")!)
//        //new WebSocket('wss://riot:oZXE0-JnjK3R2n-dtpJOGg@localhost:53811/', 'wamp');
//        socket = WebSocket(request: request, protocols: ["wss"])
//        socket?.delegate = self
//        print(socket?.currentURL ?? "")
//        socket?.disableSSLCertValidation = true
//        //socket?.enabledSSLCipherSuites = [TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256]
//
//        //socket?.request.headers = HTTPHeaders([HTTPHeader(name: "Authorization", value: "Basic \("riot:\(LCU.shared.riotPassword ?? "")".toBase64())")])
//        socket?.connect()
//        print(socket?.isConnected ?? false)
    }
    
    //MARK: - Handlers
  
    fileprivate func setupTouchBar() {
        DFRSystemModalShowsCloseBoxWhenFrontMost(true)
        
        let panda = NSCustomTouchBarItem(identifier: kPandaIdentifier)
        currentTouchBarItem = panda
        panda.view = NSButton(image: #imageLiteral(resourceName: "5005"), target: self, action: #selector(self.present(_:)))
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
        setTouchBarRunes(for: 517)
    }
    
    
    @IBAction func loadRunesToTouchBar(_ sender: Any) {
        getChampionSelect()
    }
    
    func getChampionSelect() {
        RequestWrapper.requestGETURL(Constants.endpoints.getCurrentChampionSelect(withPort: LCU.shared.port ?? ""), success: { (JSONResponse) in
            if let player = Mapper<MyTeam>().mapArray(JSONString: JSONResponse) {
                print(player[0].summonerId ?? "Failed to download current champ select")
            }
        }, failure: { (error) in
            print(error)
        })
    }
    
    fileprivate func reloadTouchBar(_ touchBar: NSTouchBar) {
        if #available(OSX 10.14, *) {
            NSTouchBar.dismissSystemModalTouchBar(self.groupTouchBar)
        } else {
            NSTouchBar.dismissSystemModalFunctionBar(self.groupTouchBar)
        }
        if #available(macOS 10.14, *) {
            NSTouchBar.presentSystemModalTouchBar(touchBar, systemTrayItemIdentifier: kPandaIdentifier)
        } else {
            NSTouchBar.presentSystemModalFunctionBar(touchBar, systemTrayItemIdentifier: kPandaIdentifier)
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
        self.groupTouchBar = groupTouchBar
        
        return self.groupTouchBar
    }
}

