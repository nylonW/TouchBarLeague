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

private let kSummonerNameIdentifier = NSTouchBarItem.Identifier("item.summonerName")
private let kPandaIdentifier = NSTouchBarItem.Identifier("item.")
private let kGroupIdentifier = NSTouchBarItem.Identifier("io.a2.Group")

class ViewController: NSViewController, NSTouchBarDelegate {

    //MARK: - Properties
    
    @IBOutlet weak var detectingLabel: NSTextField!
    
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
        
        setupTouchBar()
        print(LCU.shared)
        
        if LCU.shared.detected {
            detectingLabel.stringValue = "LoLClient detected"
        } else {
            detectingLabel.stringValue = "Couldn't detect LoLClient"
        }
    }
    
    //MARK: - Handlers
  
    fileprivate func setupTouchBar() {
        DFRSystemModalShowsCloseBoxWhenFrontMost(true)
        
        let panda = NSCustomTouchBarItem(identifier: kPandaIdentifier)
        currentTouchBarItem = panda
        panda.view = NSButton(title: "🤬", target: self, action: #selector(self.present(_:)))
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
            perkButton.view = NSButton(title: "\(identifier.rawValue)", target: self, action: #selector(self.bear(_:)))
            let imageview = NSImageView()
            imageview.image = NSImage(named: "\(identifier.rawValue)")?.resized(to: CGSize(width: 30, height: 30))
            imageview.frame.size.width = 30
            imageview.frame.size.height = 30
            perkButton.view = imageview
            return perkButton
        }
    }
    
    @objc func bear(_ sender: Any?) {
        print("First button clicked")
    }
    
    @objc func present(_ sender: Any?) {
        if #available(macOS 10.14, *) {
            NSTouchBar.presentSystemModalTouchBar(self.groupTouchBarA, systemTrayItemIdentifier: kPandaIdentifier)
        } else {
            NSTouchBar.presentSystemModalFunctionBar(self.groupTouchBarA, systemTrayItemIdentifier: kPandaIdentifier)
        }
    }
    
    
    @IBAction func loadRunesToTouchBar(_ sender: Any) {
        setTouchBarRunes(for: 517)
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

